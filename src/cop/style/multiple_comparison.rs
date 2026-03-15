use ruby_prism::Visit;

use crate::cop::{Cop, CopConfig};
use crate::diagnostic::Diagnostic;
use crate::parse::source::SourceFile;

/// Style/MultipleComparison: Avoid comparing a variable with multiple items
/// in a conditional, use `Array#include?` instead.
///
/// Corpus investigation: 70 FPs, 8 FNs.
///
/// FPs: The original `check_node` approach visited every OrNode independently.
/// For left-associative chains like `a == "x" || a == "y" || a.end_with?("z")`,
/// which parse as `((a == "x" || a == "y") || a.end_with?("z"))`, the inner
/// OrNode `a == "x" || a == "y"` fired with count=2 even though it's part of
/// a larger mixed chain. The outermost OrNode correctly returned None (due to
/// the non-`==` branch), but the inner sub-node still fired independently.
///
/// Fix: Switched to `check_source` with a visitor that tracks parent context.
/// The visitor only processes ROOT OrNodes (OrNodes whose parent is not an
/// OrNode). This matches RuboCop's `root_of_or_node` approach which walks up
/// the parent chain to find the root before processing.
pub struct MultipleComparison;

impl MultipleComparison {
    /// Recursively collect == comparisons joined by ||, returning the variable
    /// being compared if consistent, along with the comparison count.
    /// Handles OrNode (||) and CallNode (==).
    /// When AllowMethodComparison is true, comparisons where the value is a
    /// method call are skipped (returning count 0) but don't break the chain.
    fn collect_comparisons<'a>(
        node: &'a ruby_prism::Node<'a>,
        allow_method: bool,
    ) -> Option<(Vec<u8>, usize)> {
        // Handle OrNode: a == x || a == y
        if let Some(or_node) = node.as_or_node() {
            let lhs = or_node.left();
            let rhs = or_node.right();

            let lhs_result = Self::collect_comparisons(&lhs, allow_method);
            let rhs_result = Self::collect_comparisons(&rhs, allow_method);

            match (lhs_result, rhs_result) {
                (Some((lhs_var, lhs_count)), Some((rhs_var, rhs_count))) => {
                    if lhs_var == rhs_var {
                        return Some((lhs_var, lhs_count + rhs_count));
                    }
                    // Different variables but might share if one is empty (skipped method comparison)
                    if lhs_count == 0 {
                        return Some((rhs_var, rhs_count));
                    }
                    if rhs_count == 0 {
                        return Some((lhs_var, lhs_count));
                    }
                    return None;
                }
                (Some(_), None) | (None, Some(_)) => {
                    return None;
                }
                (None, None) => return None,
            }
        }

        // Handle CallNode with ==
        if let Some(call) = node.as_call_node() {
            if call.name().as_slice() == b"==" {
                let lhs = call.receiver()?;
                let rhs_args = call.arguments()?;
                let rhs_list: Vec<_> = rhs_args.arguments().iter().collect();
                if rhs_list.len() != 1 {
                    return None;
                }
                let rhs = &rhs_list[0];

                let lhs_src = lhs.location().as_slice();
                let rhs_src = rhs.location().as_slice();

                // Determine which side is the variable (lvar or method call)
                // and which is the value.
                let (var_src, value_is_call) = if lhs.as_local_variable_read_node().is_some() {
                    (lhs_src, rhs.as_call_node().is_some())
                } else if rhs.as_local_variable_read_node().is_some() {
                    (rhs_src, lhs.as_call_node().is_some())
                } else if lhs.as_call_node().is_some() && rhs.as_call_node().is_none() {
                    (lhs_src, false)
                } else if rhs.as_call_node().is_some() && lhs.as_call_node().is_none() {
                    (rhs_src, false)
                } else if lhs.as_call_node().is_some() && rhs.as_call_node().is_some() {
                    (lhs_src, true)
                } else {
                    return None;
                };

                if allow_method && value_is_call {
                    return Some((var_src.to_vec(), 0));
                }

                return Some((var_src.to_vec(), 1));
            }
        }
        None
    }
}

impl Cop for MultipleComparison {
    fn name(&self) -> &'static str {
        "Style/MultipleComparison"
    }

    fn check_source(
        &self,
        source: &SourceFile,
        parse_result: &ruby_prism::ParseResult<'_>,
        _code_map: &crate::parse::codemap::CodeMap,
        config: &CopConfig,
        diagnostics: &mut Vec<Diagnostic>,
        _corrections: Option<&mut Vec<crate::correction::Correction>>,
    ) {
        let allow_method = config.get_bool("AllowMethodComparison", true);
        let threshold = config.get_usize("ComparisonsThreshold", 2);

        let mut visitor = MultipleComparisonVisitor {
            cop: self,
            source,
            allow_method,
            threshold,
            diagnostics: Vec::new(),
            inside_or: false,
        };
        visitor.visit(&parse_result.node());
        diagnostics.extend(visitor.diagnostics);
    }
}

struct MultipleComparisonVisitor<'a> {
    cop: &'a MultipleComparison,
    source: &'a SourceFile,
    allow_method: bool,
    threshold: usize,
    diagnostics: Vec<Diagnostic>,
    /// True when we are inside a parent OrNode — child OrNodes should not fire.
    inside_or: bool,
}

impl<'a> Visit<'a> for MultipleComparisonVisitor<'a> {
    fn visit_or_node(&mut self, node: &ruby_prism::OrNode<'a>) {
        if self.inside_or {
            // We're inside a parent OrNode — this is a sub-node of a || chain.
            // Don't process it independently, but recurse for nested independent chains.
            ruby_prism::visit_or_node(self, node);
            return;
        }

        // This is a root OrNode (not nested inside another ||).
        // Process the full chain by collecting comparisons from left and right children.
        let lhs = node.left();
        let rhs = node.right();
        let lhs_result = MultipleComparison::collect_comparisons(&lhs, self.allow_method);
        let rhs_result = MultipleComparison::collect_comparisons(&rhs, self.allow_method);

        let result = match (lhs_result, rhs_result) {
            (Some((lhs_var, lhs_count)), Some((rhs_var, rhs_count))) => {
                if lhs_var == rhs_var {
                    Some(lhs_count + rhs_count)
                } else if lhs_count == 0 {
                    Some(rhs_count)
                } else if rhs_count == 0 {
                    Some(lhs_count)
                } else {
                    None
                }
            }
            _ => None,
        };

        if let Some(count) = result {
            if count >= self.threshold {
                let loc = node.location();
                let (line, column) = self.source.offset_to_line_col(loc.start_offset());
                self.diagnostics.push(self.cop.diagnostic(
                    self.source,
                    line,
                    column,
                    "Avoid comparing a variable with multiple items in a conditional, use `Array#include?` instead.".to_string(),
                ));
            }
        }

        // Recurse into children with inside_or=true so nested OrNodes don't fire
        self.inside_or = true;
        ruby_prism::visit_or_node(self, node);
        self.inside_or = false;
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    crate::cop_fixture_tests!(MultipleComparison, "cops/style/multiple_comparison");
}
