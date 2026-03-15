use crate::cop::node_type::CALL_NODE;
use crate::cop::util::{has_keyword_arg, is_dsl_call};
use crate::cop::{Cop, CopConfig};
use crate::diagnostic::{Diagnostic, Severity};
use crate::parse::source::SourceFile;

/// Rails/InverseOf -- checks `has_many`, `has_one`, and `belongs_to` associations
/// for missing `:inverse_of` option when Rails cannot automatically infer it.
///
/// ## Root causes of historical FNs (108 total, 0 FPs):
///
/// 1. **Only checked inside ClassNode bodies** -- the cop used `class_body_calls()`
///    which only found associations directly inside `class ... end` bodies. Most
///    FNs (90%+) were associations inside `included do ... end` blocks in
///    concern modules. Fixed by switching to `CALL_NODE` interested type, which
///    matches `has_many`/`has_one`/`belongs_to` calls anywhere in the file.
///
/// 2. **Missing `lambda { }` scope detection** -- the cop only checked for
///    `LambdaNode` (`-> {}`), but `lambda { order(:ordering) }` parses as a
///    `CallNode` with method name `lambda`. Fixed by also checking for
///    `CallNode` arguments with name `lambda`.
pub struct InverseOf;

impl Cop for InverseOf {
    fn name(&self) -> &'static str {
        "Rails/InverseOf"
    }

    fn default_severity(&self) -> Severity {
        Severity::Convention
    }

    fn interested_node_types(&self) -> &'static [u8] {
        &[CALL_NODE]
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
        let ignore_scopes = config.get_bool("IgnoreScopes", false);

        let call = match node.as_call_node() {
            Some(c) => c,
            None => return,
        };

        // Only match has_many, has_one, belongs_to calls without a receiver
        let is_assoc = call.receiver().is_none()
            && (is_dsl_call(&call, b"has_many")
                || is_dsl_call(&call, b"has_one")
                || is_dsl_call(&call, b"belongs_to"));

        if !is_assoc {
            return;
        }

        // Check if the call has a scope (lambda argument)
        // -> { } is a LambdaNode; lambda { } is a CallNode with name "lambda"
        let has_scope = call.arguments().is_some_and(|args| {
            args.arguments().iter().any(|a| {
                a.as_lambda_node().is_some()
                    || a.as_call_node()
                        .is_some_and(|c| c.name().as_slice() == b"lambda")
            })
        });

        // Skip associations with :through or :polymorphic -- these don't
        // need :inverse_of (RuboCop's options_ignoring_inverse_of?)
        let has_through = has_keyword_arg(&call, b"through");
        let has_polymorphic = has_keyword_arg(&call, b"polymorphic");
        if has_through || has_polymorphic {
            return;
        }

        // Only flag when :foreign_key or :conditions is specified without :inverse_of,
        // OR when a scope is present (and IgnoreScopes is false).
        let has_foreign_key = has_keyword_arg(&call, b"foreign_key");
        let has_conditions = has_keyword_arg(&call, b"conditions");
        let needs_inverse = has_foreign_key || has_conditions || (has_scope && !ignore_scopes);

        if needs_inverse && !has_keyword_arg(&call, b"inverse_of") {
            let loc = call.message_loc().unwrap_or(call.location());
            let (line, column) = source.offset_to_line_col(loc.start_offset());
            diagnostics.push(self.diagnostic(
                source,
                line,
                column,
                "Specify an `:inverse_of` option.".to_string(),
            ));
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    crate::cop_fixture_tests!(InverseOf, "cops/rails/inverse_of");

    #[test]
    fn ignore_scopes_true_allows_scope_without_inverse_of() {
        use crate::cop::CopConfig;
        use crate::testutil::assert_cop_no_offenses_full_with_config;
        use std::collections::HashMap;

        let config = CopConfig {
            options: HashMap::from([("IgnoreScopes".to_string(), serde_yml::Value::Bool(true))]),
            ..CopConfig::default()
        };
        let source =
            b"class Blog < ApplicationRecord\n  has_many :posts, -> { order(:name) }\nend\n";
        assert_cop_no_offenses_full_with_config(&InverseOf, source, config);
    }

    #[test]
    fn ignore_scopes_false_flags_scope_without_inverse_of() {
        use crate::cop::CopConfig;
        use crate::testutil::run_cop_full_with_config;

        let config = CopConfig::default();
        let source =
            b"class Blog < ApplicationRecord\n  has_many :posts, -> { order(:name) }\nend\n";
        let diags = run_cop_full_with_config(&InverseOf, source, config);
        assert!(
            !diags.is_empty(),
            "IgnoreScopes:false should flag scope without inverse_of"
        );
    }
}
