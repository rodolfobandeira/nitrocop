use crate::cop::node_type::{ELSE_NODE, IF_NODE};
use crate::cop::{Cop, CopConfig};
use crate::diagnostic::Diagnostic;
use crate::parse::source::SourceFile;

/// Style/IfInsideElse
///
/// ## Corpus investigation (2026-03-08)
///
/// Corpus oracle reported FP=23, FN=0.
///
/// FP=23: Fixed. The cop did not skip ternary outer nodes. In Prism, ternary
/// `a ? b : c` is an `IfNode` with `if_keyword_loc() == None`. When the
/// ternary's else branch contained a regular `if` expression (e.g.,
/// `a ? b : if c then d end`), the cop would incorrectly flag it.
/// RuboCop skips ternaries via `return if node.ternary?`. Fix: added an
/// early return when the outer `IfNode` has no `if_keyword_loc`.
pub struct IfInsideElse;

impl Cop for IfInsideElse {
    fn name(&self) -> &'static str {
        "Style/IfInsideElse"
    }

    fn interested_node_types(&self) -> &'static [u8] {
        &[ELSE_NODE, IF_NODE]
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
        let if_node = match node.as_if_node() {
            Some(n) => n,
            None => return,
        };

        // Skip ternary expressions (a ? b : c) — RuboCop's `return if node.ternary?`
        // In Prism, ternaries are IfNode with no if_keyword_loc.
        if if_node.if_keyword_loc().is_none() {
            return;
        }

        let _allow_if_modifier = config.get_bool("AllowIfModifier", false);

        // Check if this if has an else clause
        let else_clause = match if_node.subsequent() {
            Some(e) => e,
            None => return,
        };

        let else_node = match else_clause.as_else_node() {
            Some(e) => e,
            None => return,
        };

        // Check if the else body is a single `if` statement
        let else_stmts = match else_node.statements() {
            Some(s) => s,
            None => return,
        };

        let body: Vec<_> = else_stmts.body().iter().collect();
        if body.len() != 1 {
            return;
        }

        // Body must be an if node (not unless)
        let inner_if = match body[0].as_if_node() {
            Some(i) => i,
            None => return,
        };

        // If AllowIfModifier and the inner if is a modifier, skip
        if _allow_if_modifier {
            let loc = inner_if.location();
            let src = &source.as_bytes()[loc.start_offset()..loc.end_offset()];
            if !src.starts_with(b"if") {
                return;
            }
        }

        let loc = match inner_if.if_keyword_loc() {
            Some(l) => l,
            None => return,
        };
        let (line, column) = source.offset_to_line_col(loc.start_offset());

        diagnostics.push(self.diagnostic(
            source,
            line,
            column,
            "Convert `if` nested inside `else` to `elsif`.".to_string(),
        ));
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    crate::cop_fixture_tests!(IfInsideElse, "cops/style/if_inside_else");
}
