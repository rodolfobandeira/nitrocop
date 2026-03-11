use std::collections::{HashMap, HashSet};

use crate::cop::{Cop, CopConfig};
use crate::diagnostic::{Diagnostic, Severity};
use crate::parse::source::SourceFile;
use ruby_prism::Visit;

/// ## Corpus investigation (2026-03-08, updated 2026-03-11)
///
/// Corpus oracle reported FP=2, FN=1.
///
/// FP=2: repeated requires whose return values are consumed by different
/// wrappers (`assert require(...)`, `result = require ...`) are not duplicates
/// in RuboCop because it keys by `node.parent` with `compare_by_identity`.
/// Two requires with different parent nodes (e.g. one wrapped in `assert`,
/// another in an assignment) are independent even if they share the same
/// argument string.
///
/// FN=1: `Kernel.require` calls were not detected as duplicates of plain
/// `require`. RuboCop's node matcher accepts `{nil? (const _ :Kernel)}` as
/// valid receivers.
///
/// Fix (2026-03-11): Accept `Kernel` as equivalent receiver for require calls.
/// Key duplicates by immediate parent node (tracked via `current_parent_offset`
/// during AST walk), matching RuboCop's `@required[node.parent]` behavior.
/// Each parent node gets its own `HashSet`, so wrapped requires with different
/// parents don't conflict.
pub struct DuplicateRequire;

impl Cop for DuplicateRequire {
    fn name(&self) -> &'static str {
        "Lint/DuplicateRequire"
    }

    fn default_severity(&self) -> Severity {
        Severity::Warning
    }

    fn check_source(
        &self,
        source: &SourceFile,
        parse_result: &ruby_prism::ParseResult<'_>,
        _code_map: &crate::parse::codemap::CodeMap,
        _config: &CopConfig,
        diagnostics: &mut Vec<Diagnostic>,
        _corrections: Option<&mut Vec<crate::correction::Correction>>,
    ) {
        let mut visitor = RequireVisitor {
            cop: self,
            source,
            // Per RuboCop: keyed by parent node identity.
            // We use the parent node's start offset as a proxy for identity.
            required: HashMap::new(),
            current_parent_offset: 0,
            diagnostics: Vec::new(),
        };
        visitor.visit(&parse_result.node());
        diagnostics.extend(visitor.diagnostics);
    }
}

/// Key: (method_name, argument_string). Value: set of seen keys per parent node.
type RequireKey = (Vec<u8>, Vec<u8>);

struct RequireVisitor<'a, 'src> {
    cop: &'a DuplicateRequire,
    source: &'src SourceFile,
    /// Seen requires keyed by parent node start offset (proxy for identity).
    required: HashMap<usize, HashSet<RequireKey>>,
    /// Start offset of the current parent node being visited.
    current_parent_offset: usize,
    diagnostics: Vec<Diagnostic>,
}

impl RequireVisitor<'_, '_> {
    fn check_require_call(&mut self, node: &ruby_prism::CallNode<'_>) {
        let method_name = node.name().as_slice();

        if method_name != b"require" && method_name != b"require_relative" {
            return;
        }

        // Accept receiverless calls and Kernel.require / Kernel.require_relative
        // Handles both ConstantReadNode (`Kernel`) and ConstantPathNode (`::Kernel`)
        if let Some(receiver) = node.receiver() {
            let is_kernel = if let Some(const_node) = receiver.as_constant_read_node() {
                const_node.name().as_slice() == b"Kernel"
            } else if let Some(const_path) = receiver.as_constant_path_node() {
                const_path
                    .name()
                    .map(|n| n.as_slice() == b"Kernel")
                    .unwrap_or(false)
            } else {
                false
            };
            if !is_kernel {
                return;
            }
        }

        if let Some(args) = node.arguments() {
            let arg_list = args.arguments();
            if arg_list.len() == 1 {
                if let Some(first) = arg_list.iter().next() {
                    if let Some(s) = first.as_string_node() {
                        let key = (method_name.to_vec(), s.unescaped().to_vec());
                        let loc = node.location();
                        let parent_set =
                            self.required.entry(self.current_parent_offset).or_default();
                        if parent_set.contains(&key) {
                            let (line, column) = self.source.offset_to_line_col(loc.start_offset());
                            self.diagnostics.push(self.cop.diagnostic(
                                self.source,
                                line,
                                column,
                                "Duplicate `require` detected.".to_string(),
                            ));
                        } else {
                            parent_set.insert(key);
                        }
                    }
                }
            }
        }
    }
}

impl<'pr> Visit<'pr> for RequireVisitor<'_, '_> {
    fn visit_call_node(&mut self, node: &ruby_prism::CallNode<'pr>) {
        // Check require with current parent offset (the node that contains this call).
        self.check_require_call(node);

        // When descending into child nodes (e.g. arguments of this call),
        // this call becomes the parent. This matches RuboCop's `node.parent`.
        let prev_parent = self.current_parent_offset;
        self.current_parent_offset = node.location().start_offset();
        ruby_prism::visit_call_node(self, node);
        self.current_parent_offset = prev_parent;
    }

    fn visit_statements_node(&mut self, node: &ruby_prism::StatementsNode<'pr>) {
        let prev_parent = self.current_parent_offset;
        self.current_parent_offset = node.location().start_offset();
        ruby_prism::visit_statements_node(self, node);
        self.current_parent_offset = prev_parent;
    }

    fn visit_local_variable_write_node(&mut self, node: &ruby_prism::LocalVariableWriteNode<'pr>) {
        let prev_parent = self.current_parent_offset;
        self.current_parent_offset = node.location().start_offset();
        ruby_prism::visit_local_variable_write_node(self, node);
        self.current_parent_offset = prev_parent;
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    crate::cop_fixture_tests!(DuplicateRequire, "cops/lint/duplicate_require");
}
