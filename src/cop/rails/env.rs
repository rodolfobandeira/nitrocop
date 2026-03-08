use crate::cop::util;
use crate::cop::{Cop, CopConfig};
use crate::diagnostic::{Diagnostic, Severity};
use crate::parse::source::SourceFile;
use ruby_prism::Visit;

/// Rails/Env cop - flags `Rails.env.production?`, `Rails.env.development?`, etc.
///
/// **Complete rewrite (2026-03-08):** The original implementation was completely wrong.
/// It was flagging `ENV['RAILS_ENV']` and `ENV['RACK_ENV']`, suggesting `Rails.env` instead.
/// The actual vendor cop does the opposite: it flags predicate calls on `Rails.env`
/// (like `Rails.env.production?`) and suggests using Feature Flags instead.
///
/// The vendor cop (`vendor/rubocop-rails/lib/rubocop/cop/rails/env.rb`):
/// 1. Matches `send` calls to `:env` where receiver is `Rails` constant
/// 2. Checks if the parent is a predicate method call (method name ends with `?`)
/// 3. Has an ALLOWED_LIST of string-utility predicates that should NOT be flagged
/// 4. Does NOT flag bare `Rails.env` (only when an env-checking predicate is called on it)
pub struct Env;

/// Methods ending in `?` that are allowed on `Rails.env` (string utility methods,
/// not environment-checking predicates).
const ALLOWED_PREDICATES: &[&[u8]] = &[
    b"unicode_normalized?",
    b"exclude?",
    b"empty?",
    b"acts_like_string?",
    b"include?",
    b"is_utf8?",
    b"casecmp?",
    b"match?",
    b"starts_with?",
    b"ends_with?",
    b"start_with?",
    b"end_with?",
    b"valid_encoding?",
    b"ascii_only?",
    b"between?",
];

impl Cop for Env {
    fn name(&self) -> &'static str {
        "Rails/Env"
    }

    fn default_enabled(&self) -> bool {
        false
    }

    fn default_severity(&self) -> Severity {
        Severity::Convention
    }

    fn check_source(
        &self,
        source: &SourceFile,
        parse_result: &ruby_prism::ParseResult<'_>,
        _code_map: &crate::cop::CodeMap,
        _config: &CopConfig,
        diagnostics: &mut Vec<Diagnostic>,
        _corrections: Option<&mut Vec<crate::correction::Correction>>,
    ) {
        let mut visitor = EnvVisitor {
            cop: self,
            source,
            diagnostics: Vec::new(),
        };
        visitor.visit(&parse_result.node());
        diagnostics.extend(visitor.diagnostics);
    }
}

struct EnvVisitor<'a> {
    cop: &'a Env,
    source: &'a SourceFile,
    diagnostics: Vec<Diagnostic>,
}

impl<'a, 'pr> Visit<'pr> for EnvVisitor<'a> {
    fn visit_call_node(&mut self, node: &ruby_prism::CallNode<'pr>) {
        let method_name = node.name().as_slice();

        // We're looking for a predicate method call (ends with '?') whose receiver
        // is `Rails.env`.
        if method_name.ends_with(b"?") {
            if let Some(recv) = node.receiver() {
                if let Some(env_call) = recv.as_call_node() {
                    if env_call.name().as_slice() == b"env" {
                        if let Some(rails_recv) = env_call.receiver() {
                            if util::constant_name(&rails_recv) == Some(b"Rails") {
                                // Check the predicate is not in the allowed list
                                if !ALLOWED_PREDICATES.contains(&method_name) {
                                    let start = rails_recv.location().start_offset();
                                    let (line, column) = self.source.offset_to_line_col(start);
                                    self.diagnostics.push(
                                        self.cop.diagnostic(
                                            self.source,
                                            line,
                                            column,
                                            "Use Feature Flags or config instead of `Rails.env`."
                                                .to_string(),
                                        ),
                                    );
                                }
                            }
                        }
                    }
                }
            }
        }

        // Continue visiting child nodes
        ruby_prism::visit_call_node(self, node);
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    crate::cop_fixture_tests!(Env, "cops/rails/env");
}
