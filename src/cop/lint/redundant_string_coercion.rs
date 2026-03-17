use crate::cop::node_type::{CALL_NODE, EMBEDDED_STATEMENTS_NODE, INTERPOLATED_STRING_NODE};
use crate::cop::{Cop, CopConfig};
use crate::diagnostic::{Diagnostic, Severity};
use crate::parse::source::SourceFile;

/// Checks for redundant `.to_s` in string interpolation and in arguments to
/// `puts`, `print`, and `warn` (bare calls only, no receiver).
///
/// ## Investigation notes
/// - RuboCop's `RESTRICT_ON_SEND = %i[print puts warn]` — `p` is NOT included
///   because `p` calls `.inspect`, not `.to_s`.
/// - RuboCop's `on_send` checks `node.receiver` is nil, so `$stdout.puts x.to_s`
///   and `obj.print x.to_s` are NOT flagged.
/// - The FN=103 from the corpus were all `puts x.to_s` patterns in bare calls.
pub struct RedundantStringCoercion;

const PRINT_METHODS: &[&[u8]] = &[b"puts", b"print", b"warn"];

impl Cop for RedundantStringCoercion {
    fn name(&self) -> &'static str {
        "Lint/RedundantStringCoercion"
    }

    fn default_severity(&self) -> Severity {
        Severity::Warning
    }

    fn interested_node_types(&self) -> &'static [u8] {
        &[
            CALL_NODE,
            EMBEDDED_STATEMENTS_NODE,
            INTERPOLATED_STRING_NODE,
        ]
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
        if let Some(interp) = node.as_interpolated_string_node() {
            self.check_interpolation(source, &interp.parts(), diagnostics);
            return;
        }

        if let Some(call) = node.as_call_node() {
            self.check_print_call(source, call, diagnostics);
        }
    }
}

impl RedundantStringCoercion {
    fn check_interpolation(
        &self,
        source: &SourceFile,
        parts: &ruby_prism::NodeList<'_>,
        diagnostics: &mut Vec<Diagnostic>,
    ) {
        for part in parts {
            let embedded = match part.as_embedded_statements_node() {
                Some(e) => e,
                None => continue,
            };

            let statements = match embedded.statements() {
                Some(s) => s,
                None => continue,
            };

            let body = statements.body();
            if body.len() != 1 {
                continue;
            }

            let first = match body.first() {
                Some(n) => n,
                None => continue,
            };

            let call = match first.as_call_node() {
                Some(c) => c,
                None => continue,
            };

            if call.name().as_slice() != b"to_s" {
                continue;
            }

            if call.arguments().is_some() {
                continue;
            }

            let loc = call.message_loc().unwrap_or(call.location());
            let (line, column) = source.offset_to_line_col(loc.start_offset());
            diagnostics.push(self.diagnostic(
                source,
                line,
                column,
                "Redundant use of `Object#to_s` in interpolation.".to_string(),
            ));
        }
    }

    fn check_print_call(
        &self,
        source: &SourceFile,
        call: ruby_prism::CallNode<'_>,
        diagnostics: &mut Vec<Diagnostic>,
    ) {
        // Only bare calls (no receiver) — matches RuboCop's `return if node.receiver`
        if call.receiver().is_some() {
            return;
        }

        let method_name = call.name();
        if !PRINT_METHODS.contains(&method_name.as_slice()) {
            return;
        }

        let args = match call.arguments() {
            Some(a) => a,
            None => return,
        };

        let method_name_str = std::str::from_utf8(method_name.as_slice()).unwrap_or("puts");

        for arg in &args.arguments() {
            let arg_call = match arg.as_call_node() {
                Some(c) => c,
                None => continue,
            };

            if arg_call.name().as_slice() != b"to_s" {
                continue;
            }

            // Ensure to_s has no arguments
            if arg_call.arguments().is_some() {
                continue;
            }

            let loc = arg_call.message_loc().unwrap_or(arg_call.location());
            let (line, column) = source.offset_to_line_col(loc.start_offset());
            diagnostics.push(self.diagnostic(
                source,
                line,
                column,
                format!("Redundant use of `Object#to_s` in `{method_name_str}`."),
            ));
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    crate::cop_fixture_tests!(
        RedundantStringCoercion,
        "cops/lint/redundant_string_coercion"
    );
}
