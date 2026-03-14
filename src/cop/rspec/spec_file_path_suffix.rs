use crate::cop::node_type::{CALL_NODE, CONSTANT_PATH_NODE, CONSTANT_READ_NODE, PROGRAM_NODE};
use crate::cop::util::{RSPEC_DEFAULT_INCLUDE, is_rspec_example_group};
use crate::cop::{Cop, CopConfig};
use crate::diagnostic::{Diagnostic, Severity};
use crate::parse::source::SourceFile;

/// ## Corpus investigation (2026-03-14)
///
/// FP=2: Two files with non-`_spec.rb` paths matched because the cop was not
/// checking the receiver of `describe`/`context` calls.
///
/// - `spec/support/analyzer/98_misc.rb` had `1.describe('...')` — a method call
///   on an integer literal, NOT an RSpec example group.
/// - `spec/dummy/config/events.rb` had `WebsocketRails::EventMap.describe` — a
///   method on a constant, NOT a bare RSpec describe.
///
/// Fix: added receiver check so only receiverless calls (or `RSpec.describe`) count
/// as example groups for this cop, matching RuboCop's behavior.
pub struct SpecFilePathSuffix;

impl Cop for SpecFilePathSuffix {
    fn name(&self) -> &'static str {
        "RSpec/SpecFilePathSuffix"
    }

    fn default_severity(&self) -> Severity {
        Severity::Convention
    }

    fn default_include(&self) -> &'static [&'static str] {
        RSPEC_DEFAULT_INCLUDE
    }

    fn interested_node_types(&self) -> &'static [u8] {
        &[
            CALL_NODE,
            CONSTANT_PATH_NODE,
            CONSTANT_READ_NODE,
            PROGRAM_NODE,
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
        // Only check ProgramNode (root)
        let program = match node.as_program_node() {
            Some(p) => p,
            None => return,
        };

        let stmts = program.statements();
        let body = stmts.body();

        // Check if file contains any top-level example group (not just shared examples).
        // Must be receiverless OR RSpec.describe/::RSpec.describe to match RuboCop behavior.
        // `1.describe(...)` or `SomeModule.describe` should NOT count.
        let has_example_group = body.iter().any(|stmt| {
            if let Some(call) = stmt.as_call_node() {
                let name = call.name().as_slice();
                // Check receiver: must be None, or be RSpec/::RSpec
                let ok_receiver = match call.receiver() {
                    None => true,
                    Some(recv) => {
                        if let Some(cr) = recv.as_constant_read_node() {
                            cr.name().as_slice() == b"RSpec"
                        } else if let Some(cp) = recv.as_constant_path_node() {
                            cp.parent().is_none()
                                && cp.name().is_some_and(|n| n.as_slice() == b"RSpec")
                        } else {
                            false
                        }
                    }
                };
                if ok_receiver
                    && is_rspec_example_group(name)
                    && name != b"shared_examples"
                    && name != b"shared_examples_for"
                    && name != b"shared_context"
                {
                    return true;
                }
                // Also handle feature (receiverless only)
                if call.receiver().is_none() && name == b"feature" {
                    return true;
                }
            }
            false
        });

        if !has_example_group {
            return;
        }

        let path = source.path_str();
        if path.ends_with("_spec.rb") {
            return;
        }

        // File-level offense — report at line 1, column 0
        diagnostics.push(self.diagnostic(
            source,
            1,
            0,
            "Spec path should end with `_spec.rb`.".to_string(),
        ));
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    crate::cop_scenario_fixture_tests!(
        SpecFilePathSuffix,
        "cops/rspec/spec_file_path_suffix",
        scenario_repeated_rb = "repeated_rb.rb",
        scenario_missing_spec = "missing_spec.rb",
        scenario_wrong_ext = "wrong_ext.rb",
    );

    #[test]
    fn integer_receiver_describe_not_flagged() {
        // FP fix: 1.describe('...') has a receiver (integer) — not an RSpec example group
        // File is in spec/ dir (matches **/spec/**/*) but path is not _spec.rb
        let source = b"1.describe('method call with an argument and a block') do\n  it { expect(true).to eq(true) }\nend\n";
        let diags = crate::testutil::run_cop_full_internal(
            &SpecFilePathSuffix,
            source,
            crate::cop::CopConfig::default(),
            "spec/support/analyzer/98_misc.rb",
        );
        assert_eq!(
            diags.len(),
            0,
            "1.describe should not trigger SpecFilePathSuffix: {:?}",
            diags
        );
    }

    #[test]
    fn constant_receiver_describe_not_flagged() {
        // FP fix: SomeModule.describe has a receiver (constant) — not an RSpec example group
        let source =
            b"WebsocketRails::EventMap.describe do\n  subscribe :foo, to: SomeController\nend\n";
        let diags = crate::testutil::run_cop_full_internal(
            &SpecFilePathSuffix,
            source,
            crate::cop::CopConfig::default(),
            "spec/dummy/config/events.rb",
        );
        assert_eq!(
            diags.len(),
            0,
            "WebsocketRails::EventMap.describe should not trigger SpecFilePathSuffix: {:?}",
            diags
        );
    }
}
