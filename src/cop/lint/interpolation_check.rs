use crate::cop::node_type::STRING_NODE;
use crate::cop::{Cop, CopConfig};
use crate::diagnostic::{Diagnostic, Severity};
use crate::parse::source::SourceFile;

/// Checks for interpolation in a single quoted string.
///
/// Root cause analysis (corpus: 67 FP, 275 FN at 53.7%):
///
/// FP causes:
/// - Missing backslash-escaped `#` check: `'\#{foo}'` has `\` before `#` in the
///   source text. RuboCop's `(?<!\\)#\{.*\}` regex skips these. nitrocop was
///   flagging them because it only checked `content_bytes` for `#{` without
///   looking at the preceding character.
/// - Missing `valid_syntax?` check: patterns like `'#{%<expression>s}'` are not
///   valid Ruby interpolation. RuboCop converts to double-quoted and checks parse
///   validity. The previous `%<` heuristic was too narrow.
///
/// FN causes:
/// - Overly aggressive double-quote filter: `content_bytes.contains(&b'"')` skipped
///   ALL strings containing `"`, but RuboCop only skips when converting to
///   double-quoted produces invalid syntax. Strings like `'foo "#{bar}"'` SHOULD
///   be flagged (RuboCop corrects with `%{}`).
///
/// Fix: Use the raw source bytes (including quotes) with RuboCop-compatible
/// `(?<!\\)#\{.*\}` logic, then validate with Prism parsing instead of heuristics.
pub struct InterpolationCheck;

impl Cop for InterpolationCheck {
    fn name(&self) -> &'static str {
        "Lint/InterpolationCheck"
    }

    fn default_severity(&self) -> Severity {
        Severity::Warning
    }

    fn interested_node_types(&self) -> &'static [u8] {
        &[STRING_NODE]
    }

    fn check_node(
        &self,
        source: &SourceFile,
        node: &ruby_prism::Node<'_>,
        _parse_result: &ruby_prism::ParseResult<'_>,
        _config: &CopConfig,
        diagnostics: &mut Vec<Diagnostic>,
        _corrections: Option<&mut Vec<crate::correction::Correction>>,
    ) {
        let string_node = match node.as_string_node() {
            Some(s) => s,
            None => return,
        };

        // Only check single-quoted strings.
        // opening_loc gives us the quote character (', ", %q{, etc.)
        let opening = match string_node.opening_loc() {
            Some(loc) => loc,
            None => return, // bare string (heredoc body, %w element, etc.)
        };

        let open_slice = opening.as_slice();
        // Single-quoted: starts with ' or %q
        let is_single_quoted = open_slice == b"'" || open_slice.starts_with(b"%q");

        if !is_single_quoted {
            return;
        }

        // Get the full source span of the string node (including quotes)
        let node_start = opening.start_offset();
        let closing = match string_node.closing_loc() {
            Some(loc) => loc,
            None => return,
        };
        let node_end = closing.end_offset();
        let node_source = &source.as_bytes()[node_start..node_end];

        // Match RuboCop's regex: /(?<!\\)#\{.*\}/
        // Look for #{ not preceded by backslash in the source text
        if !has_unescaped_interpolation(node_source) {
            return;
        }

        // valid_syntax? check: convert to double-quoted and see if it parses
        if !valid_syntax_as_double_quoted(node_source) {
            return;
        }

        // Report at the string node's opening quote (matching RuboCop)
        let (line, column) = source.offset_to_line_col(node_start);
        diagnostics.push(self.diagnostic(
            source,
            line,
            column,
            "Interpolation in single quoted string detected. Use double quoted strings if you need interpolation.".to_string(),
        ));
    }
}

/// Check if the source bytes contain `#{...}` not preceded by `\`.
/// Matches RuboCop's `/(?<!\\)#\{.*\}/` regex behavior.
fn has_unescaped_interpolation(source: &[u8]) -> bool {
    let mut i = 0;
    while i + 1 < source.len() {
        if source[i] == b'#' && source[i + 1] == b'{' {
            // Check if preceded by backslash
            if i == 0 || source[i - 1] != b'\\' {
                // Check there's a closing }
                if let Some(pos) = source[i + 2..].iter().position(|&b| b == b'}') {
                    let _ = pos; // just need to know it exists
                    return true;
                }
            }
        }
        i += 1;
    }
    false
}

/// Convert the single-quoted string source to double-quoted and check if it
/// parses as valid Ruby. Matches RuboCop's `valid_syntax?` method.
///
/// RuboCop uses `ProcessedSource#valid_syntax?` which considers the source valid
/// if parsing doesn't produce fatal errors. Prism is stricter than the Parser gem —
/// it reports semantic errors like "Invalid yield" (yield outside method) as errors,
/// while the Parser gem treats these as valid syntax. We filter out known semantic
/// errors to match RuboCop behavior.
fn valid_syntax_as_double_quoted(source: &[u8]) -> bool {
    // source is the full string including quotes, e.g. b"'foo #{bar}'"
    // Replace opening ' with " and closing ' with "
    // For %q{...} strings, we need to handle differently
    let source_str = match std::str::from_utf8(source) {
        Ok(s) => s,
        Err(_) => return false,
    };

    let double_quoted = if source_str.starts_with('\'') && source_str.ends_with('\'') {
        // Simple single-quoted: 'content' -> "content"
        format!("\"{}\"", &source_str[1..source_str.len() - 1])
    } else if let Some(rest) = source_str.strip_prefix("%q") {
        // %q{content} or %q(content) etc. — convert to double-quoted
        // Find the delimiter after %q
        let open_char = match rest.chars().next() {
            Some(c) => c,
            None => return false,
        };
        let close_char = match open_char {
            '{' => '}',
            '(' => ')',
            '[' => ']',
            '<' => '>',
            c => c,
        };
        // Content is everything after the opening delimiter and before the closing
        let after_delim = &rest[open_char.len_utf8()..];
        if let Some(content) = after_delim.strip_suffix(close_char) {
            format!("\"{}\"", content)
        } else {
            return false;
        }
    } else {
        return false;
    };

    // Parse with Prism and check for syntax errors.
    // Filter out semantic errors (e.g., "Invalid yield", "Invalid retry") that
    // the Parser gem accepts but Prism rejects. These start with "Invalid" and
    // represent runtime-checked conditions, not true syntax problems.
    let result = ruby_prism::parse(double_quoted.as_bytes());
    let has_syntax_error = result.errors().any(|e| {
        let msg = e.message();
        let msg_bytes = msg.as_bytes();
        !msg_bytes.starts_with(b"Invalid ")
    });
    !has_syntax_error
}

#[cfg(test)]
mod tests {
    use super::*;
    crate::cop_fixture_tests!(InterpolationCheck, "cops/lint/interpolation_check");

    #[test]
    fn test_has_unescaped_interpolation() {
        assert!(has_unescaped_interpolation(b"'hello #{name}'"));
        assert!(!has_unescaped_interpolation(b"'hello \\#{name}'"));
        assert!(!has_unescaped_interpolation(b"'hello world'"));
        assert!(has_unescaped_interpolation(b"'#{bar}'"));
    }

    #[test]
    fn test_valid_syntax_as_double_quoted() {
        assert!(valid_syntax_as_double_quoted(b"'hello #{name}'"));
        assert!(valid_syntax_as_double_quoted(b"'#{bar}'"));
        assert!(valid_syntax_as_double_quoted(b"'foo \"#{bar}\"'"));
        assert!(!valid_syntax_as_double_quoted(b"'#{%<expression>s}'"));
    }

    #[test]
    fn test_valid_syntax_yield() {
        // yield.upcase is valid Ruby syntax (yield outside method is a semantic
        // error that Prism flags but Parser gem accepts)
        assert!(valid_syntax_as_double_quoted(
            b"'THIS. IS. #{yield.upcase}!'"
        ));
    }
}
