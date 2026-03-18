use crate::cop::node_type::CALL_NODE;
use crate::cop::{Cop, CopConfig};
use crate::diagnostic::Diagnostic;
use crate::parse::source::SourceFile;

/// Style/RedundantRegexpArgument flags regexp arguments that could be strings.
///
/// ## Investigation findings (2026-03-18)
///
/// ### FN root cause fixed:
/// - `is_deterministic_regexp` rejected ALL backslash escapes. RuboCop's
///   LITERAL_REGEX allows `\` followed by non-special chars (e.g., `\.`, `\/`, `\-`).
///   Only regex-specific escapes like `\d`, `\w`, `\s`, `\b`, `\A`, etc. make a
///   regexp non-deterministic. Updated to match RuboCop's LITERAL_REGEX behavior.
pub struct RedundantRegexpArgument;

/// Methods where a regexp argument can be replaced with a string.
/// Must match vendor RuboCop's RESTRICT_ON_SEND list.
const TARGET_METHODS: &[&[u8]] = &[
    b"byteindex",
    b"byterindex",
    b"gsub",
    b"gsub!",
    b"partition",
    b"rpartition",
    b"scan",
    b"split",
    b"start_with?",
    b"sub",
    b"sub!",
];

impl Cop for RedundantRegexpArgument {
    fn name(&self) -> &'static str {
        "Style/RedundantRegexpArgument"
    }

    fn interested_node_types(&self) -> &'static [u8] {
        &[CALL_NODE]
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
        let call = match node.as_call_node() {
            Some(c) => c,
            None => return,
        };

        let name = call.name().as_slice();
        if !TARGET_METHODS.contains(&name) {
            return;
        }

        let args = match call.arguments() {
            Some(a) => a,
            None => return,
        };

        let arg_list: Vec<_> = args.arguments().iter().collect();
        if arg_list.is_empty() {
            return;
        }

        // First argument must be a simple regexp literal
        let regex = match arg_list[0].as_regular_expression_node() {
            Some(r) => r,
            None => return,
        };

        // Check if the regex is deterministic (no special regex chars)
        let content = regex.content_loc().as_slice();
        if !is_deterministic_regexp(content) {
            return;
        }

        // Skip single space regexps: / / is idiomatic
        if content == b" " {
            return;
        }

        // Check for flags by looking at the closing loc
        // If the regexp has flags like /foo/i, skip
        let closing = regex.closing_loc();
        let close_bytes = closing.as_slice();
        // Closing should just be "/" with no trailing flags
        if close_bytes.len() > 1 {
            return;
        }

        let loc = arg_list[0].location();
        let (line, column) = source.offset_to_line_col(loc.start_offset());
        diagnostics.push(self.diagnostic(
            source,
            line,
            column,
            "Use string `\"` instead of regexp `/` as the argument.".to_string(),
        ));
    }
}

/// Check if regexp content is deterministic (matches a fixed string).
/// Matches RuboCop's DETERMINISTIC_REGEX which uses LITERAL_REGEX:
///   LITERAL_REGEX = /[\w\s\-,"'!#%&<>=;:`~\/]|\\[^AbBdDgGhHkpPRwWXsSzZ0-9]/
/// Each character must be either a literal char or a backslash-escaped literal char.
fn is_deterministic_regexp(content: &[u8]) -> bool {
    if content.is_empty() {
        return false;
    }

    // Regex-special escape chars that indicate a non-deterministic pattern
    const REGEX_ESCAPE_SPECIALS: &[u8] = b"AbBdDgGhHkpPRwWXsSzZ0123456789";

    let mut i = 0;
    while i < content.len() {
        let b = content[i];
        if b == b'\\' {
            // Backslash escape: next char must not be a regex-special escape
            i += 1;
            if i >= content.len() {
                return false; // trailing backslash
            }
            if REGEX_ESCAPE_SPECIALS.contains(&content[i]) {
                return false;
            }
            // Escaped literal char — this is fine (e.g., \., \/, \-)
        } else {
            // Unescaped character must be in the literal set
            // RuboCop allows: \w (word chars), \s (whitespace), and specific punctuation
            match b {
                // Regex metacharacters that are NOT literal
                b'.' | b'*' | b'+' | b'?' | b'(' | b')' | b'[' | b']' | b'{' | b'}' | b'^'
                | b'$' | b'|' => return false,
                // Everything else is literal (alphanumeric, underscore, space, punctuation)
                _ => {}
            }
        }
        i += 1;
    }
    true
}

#[cfg(test)]
mod tests {
    use super::*;
    crate::cop_fixture_tests!(
        RedundantRegexpArgument,
        "cops/style/redundant_regexp_argument"
    );
}
