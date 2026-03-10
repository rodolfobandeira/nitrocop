use crate::cop::node_type::{CALL_NODE, INTERPOLATED_STRING_NODE, STRING_NODE, SYMBOL_NODE};
use crate::cop::{Cop, CopConfig};
use crate::diagnostic::{Diagnostic, Severity};
use crate::parse::source::SourceFile;

/// Lint/SymbolConversion checks for uses of literal strings converted to a symbol
/// where a literal symbol could be used instead, and for unnecessarily quoted symbols.
///
/// Root causes of prior FNs (1,539 total, 81.1% match rate):
/// 1. Missing `intern` method handling — only `to_sym` was checked, not `intern`
/// 2. Missing standalone quoted symbol detection — `:"foo"`, `:'bar'` were not flagged
/// 3. Missing `dstr.to_sym` / `dstr.intern` — interpolated strings not handled
/// 4. Missing quoted symbol as hash value — `{ foo: :'bar' }` not detected
/// 5. Missing rocket-style quoted symbol keys — `{ :'foo' => val }` not detected
/// 6. Wrong message format for to_sym/intern — said "detected" instead of showing correction
/// 7. Missing `!` and `?` suffix handling for hash keys — `{ 'foo!': val }` not detected
pub struct SymbolConversion;

/// Check if a symbol value can be represented as a bare (unquoted) symbol.
/// Returns true for identifiers like `foo`, `foo_bar`, `foo!`, `foo?`, `foo=`.
fn can_be_bare_symbol(value: &[u8]) -> bool {
    if value.is_empty() {
        return false;
    }
    // First char must be letter or underscore
    if !value[0].is_ascii_alphabetic() && value[0] != b'_' {
        return false;
    }
    // Last char can be !, ?, or = (method-like symbols)
    let (main, _suffix) = if let Some(&last) = value.last() {
        if last == b'!' || last == b'?' || last == b'=' {
            (&value[..value.len() - 1], Some(last))
        } else {
            (value, None)
        }
    } else {
        return false;
    };
    // All main chars must be alphanumeric or underscore
    main.iter().all(|&b| b.is_ascii_alphanumeric() || b == b'_')
}

/// Check if a symbol value can be a bare hash key (no quotes needed in colon-style).
/// Same as bare symbol but excludes `=` suffix (e.g., `==` is not valid as `==:`).
/// Also requires first char to be alphanumeric or underscore (operators like `+` are excluded).
fn can_be_bare_hash_key(value: &[u8]) -> bool {
    if value.is_empty() {
        return false;
    }
    // First char must be letter, digit, or underscore (RuboCop: /\A[a-z0-9_]/i)
    if !value[0].is_ascii_alphanumeric() && value[0] != b'_' {
        return false;
    }
    // Last char can be ! or ? for hash keys (not =)
    let main = if let Some(&last) = value.last() {
        if last == b'!' || last == b'?' {
            &value[..value.len() - 1]
        } else {
            value
        }
    } else {
        return false;
    };
    main.iter().all(|&b| b.is_ascii_alphanumeric() || b == b'_')
}

/// Compute the correction string for a symbol value.
/// Returns e.g. `:foo` for simple symbols, `:"foo-bar"` for ones needing quoting.
fn symbol_correction(value: &[u8]) -> Option<String> {
    let value_str = std::str::from_utf8(value).ok()?;
    if can_be_bare_symbol(value) {
        Some(format!(":{value_str}"))
    } else {
        Some(format!(":\"{}\"", value_str))
    }
}

impl Cop for SymbolConversion {
    fn name(&self) -> &'static str {
        "Lint/SymbolConversion"
    }

    fn default_severity(&self) -> Severity {
        Severity::Warning
    }

    fn interested_node_types(&self) -> &'static [u8] {
        &[
            CALL_NODE,
            STRING_NODE,
            SYMBOL_NODE,
            INTERPOLATED_STRING_NODE,
        ]
    }

    fn check_node(
        &self,
        source: &SourceFile,
        node: &ruby_prism::Node<'_>,
        _parse_result: &ruby_prism::ParseResult<'_>,
        config: &CopConfig,
        diagnostics: &mut Vec<Diagnostic>,
        _corrections: Option<&mut Vec<crate::correction::Correction>>,
    ) {
        let _style = config.get_str("EnforcedStyle", "strict");

        // Check SymbolNode: quoted symbols (standalone or hash keys)
        if let Some(sym) = node.as_symbol_node() {
            self.check_symbol_node(source, &sym, diagnostics);
            return;
        }

        // Check CallNode: .to_sym / .intern patterns
        if let Some(call) = node.as_call_node() {
            self.check_call_node(source, &call, diagnostics);
        }
    }
}

impl SymbolConversion {
    /// Check a SymbolNode for unnecessary quoting.
    /// Handles:
    /// - Standalone quoted symbols: `:"foo"`, `:'bar'`
    /// - Hash keys (colon-style): `'foo': val`, `"foo": val`
    /// - Hash keys/values (rocket-style): `:'foo' => val`, `{ foo: :'bar' }`
    fn check_symbol_node(
        &self,
        source: &SourceFile,
        sym: &ruby_prism::SymbolNode<'_>,
        diagnostics: &mut Vec<Diagnostic>,
    ) {
        let src = sym.location().as_slice();
        let value = sym.unescaped();

        // Determine what kind of symbol this is based on source representation
        let opening = sym.opening_loc().map(|l| l.as_slice());

        // Check if this is a hash key in colon-style: 'foo': or "foo":
        // In Prism, these have opening_loc of "'" or "\"" and source ends with ':
        let is_colon_hash_key = match opening {
            Some(b"'" | b"\"") => src.ends_with(b"':") || src.ends_with(b"\":"),
            _ => false,
        };

        if is_colon_hash_key {
            // Hash key with colon style: 'foo': val or "foo": val
            // Only flag if the value can be a bare hash key
            if can_be_bare_hash_key(value) {
                let value_str = match std::str::from_utf8(value) {
                    Ok(s) => s,
                    Err(_) => return,
                };
                let loc = sym.location();
                let (line, column) = source.offset_to_line_col(loc.start_offset());
                diagnostics.push(self.diagnostic(
                    source,
                    line,
                    column,
                    format!("Unnecessary symbol conversion; use `{value_str}:` instead."),
                ));
            }
            return;
        }

        // For standalone symbols or rocket-style hash keys/values:
        // Check if the symbol is unnecessarily quoted
        // Opening must be :" or :' (quoted symbol syntax)
        match opening {
            Some(b":\"" | b":'") => {}
            _ => return,
        }

        // If the value needs quoting (contains non-identifier chars), it's fine
        if !can_be_bare_symbol(value) {
            return;
        }

        // Value ends with = is allowed (setter methods like `foo=`)
        if value.last() == Some(&b'=') {
            return;
        }

        // The symbol is unnecessarily quoted
        let correction = match symbol_correction(value) {
            Some(c) => c,
            None => return,
        };

        let loc = sym.location();
        let (line, column) = source.offset_to_line_col(loc.start_offset());
        diagnostics.push(self.diagnostic(
            source,
            line,
            column,
            format!("Unnecessary symbol conversion; use `{correction}` instead."),
        ));
    }

    /// Check a CallNode for .to_sym / .intern on string/symbol/dstr receivers.
    fn check_call_node(
        &self,
        source: &SourceFile,
        call: &ruby_prism::CallNode<'_>,
        diagnostics: &mut Vec<Diagnostic>,
    ) {
        let method_name = call.name().as_slice();

        // Must be .to_sym or .intern
        if method_name != b"to_sym" && method_name != b"intern" {
            return;
        }

        // Must have no arguments
        if call.arguments().is_some() {
            return;
        }

        let recv = match call.receiver() {
            Some(r) => r,
            None => return,
        };

        // String receiver: "foo".to_sym
        if let Some(str_node) = recv.as_string_node() {
            let value = str_node.unescaped();
            let correction = match symbol_correction(value) {
                Some(c) => c,
                None => return,
            };
            let loc = call.location();
            let (line, column) = source.offset_to_line_col(loc.start_offset());
            diagnostics.push(self.diagnostic(
                source,
                line,
                column,
                format!("Unnecessary symbol conversion; use `{correction}` instead."),
            ));
            return;
        }

        // Symbol receiver: :foo.to_sym
        if let Some(sym_node) = recv.as_symbol_node() {
            let value = sym_node.unescaped();
            let correction = match symbol_correction(value) {
                Some(c) => c,
                None => return,
            };
            let loc = call.location();
            let (line, column) = source.offset_to_line_col(loc.start_offset());
            diagnostics.push(self.diagnostic(
                source,
                line,
                column,
                format!("Unnecessary symbol conversion; use `{correction}` instead."),
            ));
            return;
        }

        // Interpolated string receiver: "foo-#{bar}".to_sym
        if let Some(dstr) = recv.as_interpolated_string_node() {
            // Reconstruct the interpolated content from source
            let dstr_loc = dstr.location();
            let dstr_src = dstr_loc.as_slice();
            // Strip the surrounding quotes from the dstr source
            let inner = if dstr_src.starts_with(b"\"") && dstr_src.ends_with(b"\"") {
                &dstr_src[1..dstr_src.len() - 1]
            } else {
                return; // heredoc or other form, skip
            };
            let inner_str = match std::str::from_utf8(inner) {
                Ok(s) => s,
                Err(_) => return,
            };
            let correction = format!(":\"{}\"", inner_str);
            let loc = call.location();
            let (line, column) = source.offset_to_line_col(loc.start_offset());
            diagnostics.push(self.diagnostic(
                source,
                line,
                column,
                format!("Unnecessary symbol conversion; use `{correction}` instead."),
            ));
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    crate::cop_fixture_tests!(SymbolConversion, "cops/lint/symbol_conversion");
}
