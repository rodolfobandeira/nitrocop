use crate::cop::{Cop, CopConfig};
use crate::diagnostic::Diagnostic;
use crate::parse::source::SourceFile;

use super::extract_gem_name;

pub struct GemComment;

/// ## Corpus investigation (2026-03-03)
///
/// Corpus oracle reported FP=10, FN=16 (after prior fixes).
///
/// ### FP=10 — FIXED (commit 0a40768)
///
/// All 10 FPs were from `extract_gem_name` (in `mod.rs`) matching lines where the gem
/// "name" was a variable, interpolation, or method call. The function found the first
/// quoted string anywhere on the line, which picked up argument values rather than gem
/// names. Examples:
///   - `gem db_gem, get_env("DB_GEM_VERSION")` → extracted "DB_GEM_VERSION"
///   - `gem plugin_name, :git => "https://..."` → extracted URL fragment
///   - `gem "social_stream-#{ g }"` → extracted interpolated string
///   - `gem ENV.fetch('MODEL_PARSER', nil)` → extracted "MODEL_PARSER"
///   - `gem tty_gem["name"], tty_gem["version"]` → extracted "name"
///
/// Fix: `extract_gem_name` now requires the first non-whitespace character after `gem `
/// to be a quote (`'` or `"`), and rejects names containing `#{` (interpolation).
///
/// ### FN=16 — DEFERRED (needs `check_lines` → `check_source` rewrite)
///
/// All 16 FNs share the same pattern: a gem declaration with a trailing modifier
/// `if`/`unless` that has a comment on the preceding line. nitrocop sees the comment
/// and considers the gem as documented, but RuboCop still flags it as missing a comment.
///
/// Affected repos (16 FN across 15 repos):
///   - refinery/Gemfile:8,11 — `gem 'rails' if ...` / `gem 'mutex_m' if ...`
///   - apipie-rails/Gemfile:17 — `gem 'net-smtp' if Gem.ruby_version >= ...`
///   - asciidoctor-pdf/Gemfile:22 — `gem 'rouge' unless ENV['ROUGE_VERSION'] == 'false'`
///   - asciidoctor/Gemfile:16 — `gem 'pygments.rb' if ENV.key? 'PYGMENTS_VERSION'`
///   - mysql2/Gemfile:28 — `gem 'mysql' if Gem::Version.new(RUBY_VERSION) < ...`
///   - carrierwave/Gemfile:8 — `gem "fog-google" if RUBY_VERSION.to_f < 2.7`
///   - draper/Gemfile:32 — `gem 'mongoid' unless rails_version == 'edge'`
///   - endoflife.date/Gemfile:23 — `gem "wdm" if Gem.win_platform?`
///   - jekyll/Gemfile:27 — `gem "mutex_m" if RUBY_VERSION >= "3.4"`
///   - opal/Gemfile:18 — `gem 'puma' unless RUBY_ENGINE == 'truffleruby'`
///   - rack-contrib/Gemfile:22 — `gem 'cgi' if RUBY_VERSION >= '2.7.0' && ...`
///   - rubocop/Gemfile:18 — `gem 'ruby-lsp' if RUBY_VERSION >= '3.0'`
///   - grape-swagger/Gemfile:44 — `gem 'ostruct' if Gem::Version.new(...)`
///   - stripe-ruby/Gemfile:27 — `gem "rubocop" if RUBY_VERSION >= "2.7"`
///   - activerecord-import/Gemfile:30 — `gem "seamless_database_pool" if ...`
///
/// Root cause analysis:
///
/// nitrocop uses a line-based heuristic: "if the line above is a comment, skip."
/// RuboCop uses AST-level comment association via `preceding_comment?` which calls
/// `processed_source.comment_at_line(node.first_line - 1)`. The key difference:
/// RuboCop resolves the gem call's AST node position, which for modifier if/unless
/// is the LINE OF THE GEM CALL, not the if/unless wrapper. When there's a modifier
/// conditional, the AST node for `gem 'x' if cond` starts at the `gem` keyword.
/// RuboCop then checks `comment_at_line(gem_line - 1)`.
///
/// So in principle RuboCop should also find the preceding comment. The discrepancy
/// likely comes from one of:
///   1. The comment is associated with the if/unless node in RuboCop's AST rather
///      than the gem send node, so `comment_at_line` sees it as belonging to the
///      conditional, not the gem.
///   2. RuboCop's `gem_declarations` node search `(send nil? :gem str ...)` may not
///      match some of these (e.g., `gem 'x', ENV['Y'] if ...` where the 2nd arg is
///      not a `str` node) — but the FN means RuboCop IS matching them.
///   3. Some comments are multi-line (e.g., carrierwave has `# See https://...` then
///      `# ...restriction.`), and RuboCop might require the comment to be on the
///      immediately preceding line with no gap.
///
/// Previous fix attempt (reverted): tried ignoring preceding comments for gems with
/// modifier conditionals. This eliminated all FN but caused 13 new FP (gems with
/// modifier conditionals that genuinely had no comment were now also skipped).
/// Score went from FP=0/FN=1 to FP=13/FN=0.
///
/// To fix correctly, this cop needs to be rewritten from `check_lines` to
/// `check_source` (AST-based), using Prism's comment API to associate comments with
/// gem CallNodes. The AST approach would:
///   1. Find all `gem 'name'` CallNodes (like DuplicatedGem's visitor does)
///   2. For each, check `parse_result.comments()` for a comment on `node.line - 1`
///   3. Handle modifier if/unless wrapping (the CallNode is inside an IfNode —
///      use the CallNode's location, not the IfNode's)
///   4. Also handle inline comments (comment on the same line as the gem call)
impl Cop for GemComment {
    fn name(&self) -> &'static str {
        "Bundler/GemComment"
    }

    fn default_enabled(&self) -> bool {
        false
    }

    fn default_include(&self) -> &'static [&'static str] {
        &["**/*.gemfile", "**/Gemfile", "**/gems.rb"]
    }

    fn check_lines(
        &self,
        source: &SourceFile,
        config: &CopConfig,
        diagnostics: &mut Vec<Diagnostic>,
        _corrections: Option<&mut Vec<crate::correction::Correction>>,
    ) {
        let ignored_gems = config.get_string_array("IgnoredGems").unwrap_or_default();
        let only_for = config.get_string_array("OnlyFor").unwrap_or_default();
        let check_version_specifiers = only_for.iter().any(|s| s == "version_specifiers");

        let lines: Vec<&[u8]> = source.lines().collect();
        let mut in_block_comment = false;

        for (i, line) in lines.iter().enumerate() {
            let line_str = std::str::from_utf8(line).unwrap_or("");
            let trimmed = line_str.trim_start();

            if in_block_comment {
                if trimmed.starts_with("=end") {
                    in_block_comment = false;
                }
                continue;
            }
            if trimmed.starts_with("=begin") {
                if !trimmed.contains("=end") {
                    in_block_comment = true;
                }
                continue;
            }

            if let Some(gem_name) = extract_gem_name(line_str) {
                // Skip ignored gems
                if ignored_gems.iter().any(|g| g == gem_name) {
                    continue;
                }

                // When OnlyFor includes "version_specifiers", only flag gems with version constraints
                if check_version_specifiers && !has_version_specifier(line_str) {
                    continue;
                }

                // Check if the preceding line is a comment, or this line has an inline comment
                let has_comment = has_inline_comment(line_str)
                    || (i > 0
                        && std::str::from_utf8(lines[i - 1])
                            .unwrap_or("")
                            .trim()
                            .starts_with('#')
                        && !is_magic_comment(
                            std::str::from_utf8(lines[i - 1]).unwrap_or("").trim(),
                        ));

                if !has_comment {
                    let line_num = i + 1;
                    diagnostics.push(self.diagnostic(
                        source,
                        line_num,
                        0,
                        "Missing gem description comment.".to_string(),
                    ));
                }
            }
        }
    }
}

/// Check if a gem declaration line has a version specifier.
/// Version specifiers look like: '~> 1.0', '>= 2.0', '1.0', etc.
fn has_version_specifier(line: &str) -> bool {
    let trimmed = line.trim();
    // After `gem 'name'`, look for version-like arguments
    // Find the closing quote of the gem name
    let first_quote = match trimmed.find(['\'', '"']) {
        Some(idx) => idx,
        None => return false,
    };
    let quote_char = trimmed.as_bytes()[first_quote];
    let after_name_start = first_quote + 1;
    let name_end = match trimmed[after_name_start..].find(|c: char| c as u8 == quote_char) {
        Some(idx) => after_name_start + idx + 1,
        None => return false,
    };

    let rest = &trimmed[name_end..];
    // Look for version string patterns after a comma
    // A version string starts with optional operator (>=, ~>, <=, >, <, =, !=) then digits
    if let Some(comma_idx) = rest.find(',') {
        let after_comma = rest[comma_idx + 1..].trim();
        // Check if next argument is a quoted version string
        if after_comma.starts_with('\'') || after_comma.starts_with('"') {
            let q = after_comma.as_bytes()[0];
            if let Some(end) = after_comma[1..].find(|c: char| c as u8 == q) {
                let val = &after_comma[1..1 + end];
                if is_version_string(val) {
                    return true;
                }
            }
        }
    }
    false
}

/// Check if a string looks like a version specifier.
/// Examples: "1.0", "~> 1.0", ">= 2.0", "< 3.0"
fn is_version_string(s: &str) -> bool {
    let s = s.trim();
    let s = s
        .trim_start_matches("~>")
        .trim_start_matches(">=")
        .trim_start_matches("<=")
        .trim_start_matches("!=")
        .trim_start_matches('>')
        .trim_start_matches('<')
        .trim_start_matches('=')
        .trim();
    // Should start with a digit
    s.starts_with(|c: char| c.is_ascii_digit())
}

/// Check if the line has an inline comment (# after the gem declaration).
fn has_inline_comment(line: &str) -> bool {
    // Simple heuristic: look for # that's not inside quotes
    let mut in_single = false;
    let mut in_double = false;
    for ch in line.chars() {
        match ch {
            '\'' if !in_double => in_single = !in_single,
            '"' if !in_single => in_double = !in_double,
            '#' if !in_single && !in_double => return true,
            _ => {}
        }
    }
    false
}

fn is_magic_comment(line: &str) -> bool {
    let trimmed = line.trim_start();
    if !trimmed.starts_with('#') {
        return false;
    }

    let body = trimmed.trim_start_matches('#').trim_start();
    body.starts_with("frozen_string_literal:")
        || body.starts_with("encoding:")
        || body.starts_with("coded by:")
        || body.starts_with("-*-")
}

#[cfg(test)]
mod tests {
    use super::*;
    crate::cop_fixture_tests!(GemComment, "cops/bundler/gem_comment");
}
