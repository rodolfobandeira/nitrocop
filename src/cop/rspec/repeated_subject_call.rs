use crate::cop::node_type::{BLOCK_NODE, CALL_NODE, STATEMENTS_NODE};
use crate::cop::util::{RSPEC_DEFAULT_INCLUDE, is_rspec_example};
use crate::cop::{Cop, CopConfig};
use crate::diagnostic::{Diagnostic, Severity};
use crate::parse::source::SourceFile;

/// RSpec/RepeatedSubjectCall: Flag calling `subject` multiple times in the same example
/// when at least one call is inside a block (expect { subject }).
///
/// ## FP fix (2026-03): align with RuboCop's `detect_offense` filtering
///
/// RuboCop only flags a repeated `subject` call when ALL three conditions hold:
/// 1. `subject` is NOT chained (`subject.foo` — skip, subject is a receiver)
/// 2. `subject`'s parent is NOT a send/call node (e.g., `expect(subject)` — skip,
///    subject is an argument)
/// 3. `subject` is inside an `expect { ... }` block (not just any block)
///
/// The previous implementation only tracked `in_block` (any block) and didn't
/// check condition 2. This caused 42 FPs from patterns like:
///   `expect(subject).to be_allowed(resource)` inside `.each` loops —
///   subject as an argument was incorrectly counted as a flaggable call.
pub struct RepeatedSubjectCall;

impl Cop for RepeatedSubjectCall {
    fn name(&self) -> &'static str {
        "RSpec/RepeatedSubjectCall"
    }

    fn default_severity(&self) -> Severity {
        Severity::Convention
    }

    fn default_include(&self) -> &'static [&'static str] {
        RSPEC_DEFAULT_INCLUDE
    }

    fn interested_node_types(&self) -> &'static [u8] {
        &[BLOCK_NODE, CALL_NODE, STATEMENTS_NODE]
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
        // Look for example blocks (it/specify/etc.)
        let call = match node.as_call_node() {
            Some(c) => c,
            None => return,
        };

        let name = call.name().as_slice();
        if !is_rspec_example(name) {
            return;
        }
        if call.receiver().is_some() {
            return;
        }

        let block = match call.block() {
            Some(b) => b,
            None => return,
        };
        let block_node = match block.as_block_node() {
            Some(b) => b,
            None => return,
        };
        let body = match block_node.body() {
            Some(b) => b,
            None => return,
        };

        // Find all `subject` calls in the example body.
        // Each entry: (line, col, is_in_expect_block, is_arg_of_call, is_chained)
        let mut subject_calls: Vec<SubjectCall> = Vec::new();
        collect_subject_calls(source, &body, false, false, &mut subject_calls);

        if subject_calls.len() <= 1 {
            return;
        }

        // Flag 2nd+ subject calls that are:
        // - inside an expect { } block
        // - NOT chained (subject.foo)
        // - NOT an argument to another call (expect(subject))
        let mut seen_first = false;
        for call in &subject_calls {
            if !seen_first {
                seen_first = true;
                continue;
            }
            if call.in_expect_block && !call.is_chained && !call.is_arg_of_call {
                diagnostics.push(self.diagnostic(
                    source,
                    call.line,
                    call.col,
                    "Calls to subject are memoized, this block is misleading".to_string(),
                ));
            }
        }
    }
}

struct SubjectCall {
    line: usize,
    col: usize,
    in_expect_block: bool,
    is_chained: bool,
    is_arg_of_call: bool,
}

fn collect_subject_calls(
    source: &SourceFile,
    node: &ruby_prism::Node<'_>,
    in_expect_block: bool,
    is_receiver: bool,
    results: &mut Vec<SubjectCall>,
) {
    if let Some(stmts) = node.as_statements_node() {
        for stmt in stmts.body().iter() {
            collect_subject_calls(source, &stmt, in_expect_block, false, results);
        }
        return;
    }

    if let Some(call) = node.as_call_node() {
        let name = call.name().as_slice();

        // Check if this is a bare `subject` call (no receiver).
        if name == b"subject" && call.receiver().is_none() {
            let loc = call.location();
            let (line, col) = source.offset_to_line_col(loc.start_offset());
            results.push(SubjectCall {
                line,
                col,
                in_expect_block,
                is_chained: is_receiver,
                // subject is an argument if it's not a receiver and it's inside
                // the arguments of another call — tracked by the caller passing
                // is_arg=true via the arguments recursion below
                is_arg_of_call: false, // will be set by caller
            });
        }

        // Recurse into receiver, marking it as a receiver context
        if let Some(recv) = call.receiver() {
            collect_subject_calls(source, &recv, in_expect_block, true, results);
        }

        // Check arguments — subject here is an argument to this call
        if let Some(args) = call.arguments() {
            for arg in args.arguments().iter() {
                let before = results.len();
                collect_subject_calls(source, &arg, in_expect_block, false, results);
                // Mark any subject calls found in args as arguments of a call
                for r in &mut results[before..] {
                    r.is_arg_of_call = true;
                }
            }
        }

        // Check the call's own block — track if this is an `expect` block
        if let Some(block) = call.block() {
            if let Some(block_node) = block.as_block_node() {
                if let Some(body) = block_node.body() {
                    let is_expect =
                        name == b"expect" || (in_expect_block && call.receiver().is_none());
                    collect_subject_calls(
                        source,
                        &body,
                        in_expect_block || is_expect,
                        false,
                        results,
                    );
                }
            }
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    crate::cop_fixture_tests!(RepeatedSubjectCall, "cops/rspec/repeated_subject_call");
}
