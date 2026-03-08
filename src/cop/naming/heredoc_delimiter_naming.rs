use crate::cop::node_type::{
    INTERPOLATED_STRING_NODE, INTERPOLATED_X_STRING_NODE, STRING_NODE, X_STRING_NODE,
};
use crate::cop::{Cop, CopConfig};
use crate::diagnostic::Diagnostic;
use crate::parse::source::SourceFile;

/// ## Corpus investigation (2026-03-04)
///
/// Corpus oracle reported FP=14,002, FN=14,273.
///
/// FP=14,002 / FN=14,273: the primary divergence was offense location.
/// nitrocop reported at heredoc opening (`<<~END`) while RuboCop reports at the
/// closing delimiter token (`END`). This produced symmetric location mismatches
/// at large scale. This implementation now reports at `closing_loc()` and also
/// handles non-word delimiters (for example `<<-'+'`) as offenses.
///
/// ## Corpus investigation (2026-03-08)
///
/// Corpus oracle reported FP=162, FN=14.
///
/// FP=162: `is_word_delimiter()` required ALL chars to be word chars, but
/// RuboCop's check is `/\w/.match?(delimiters)` which only requires at least
/// ONE word character. Delimiters like `MY.SQL`, `END-BLOCK`, `my_template.html`
/// were falsely flagged because they contain dots/hyphens. Fixed by changing to
/// `contains_word_char()` which uses `.any()` instead of `.all()`.
///
/// FN=14: backtick heredocs (`<<~`CMD``) use `InterpolatedXStringNode` /
/// `XStringNode` which were not handled. Added these node types.
///
/// Also fixed: plain string patterns in ForbiddenDelimiters (e.g., `END` without
/// `/` delimiters) are now treated as regex via `Regexp.new()` matching RuboCop.
pub struct HeredocDelimiterNaming;

// Default forbidden patterns: EO followed by one uppercase letter, or END.
fn is_default_forbidden_delimiter(delimiter: &str) -> bool {
    // Default: /(^|\s)(EO[A-Z]{1}|END)(\s|$)/i
    let d = delimiter.to_uppercase();
    if d == "END" {
        return true;
    }
    if d.len() == 3 && d.starts_with("EO") && d.as_bytes()[2].is_ascii_alphabetic() {
        return true;
    }
    false
}

/// Returns true if delimiter contains at least one word character (\w).
/// Matches RuboCop's `/\w/.match?(delimiters)` check — a delimiter is
/// considered "wordy" if it has ANY word character, not if ALL chars are
/// word characters.
fn contains_word_char(delimiter: &str) -> bool {
    delimiter
        .as_bytes()
        .iter()
        .any(|b| b.is_ascii_alphanumeric() || *b == b'_')
}

fn delimiter_matches_pattern(delimiter: &str, raw_pattern: &str) -> bool {
    let pattern = raw_pattern.trim();
    if pattern.is_empty() {
        return false;
    }

    // RuboCop config stores regexes as strings like `/.../i`.
    // Plain strings are also treated as regex via Regexp.new() in RuboCop.
    let (regex_body, flags) = if let Some(stripped) = pattern.strip_prefix('/') {
        if let Some(last_slash) = stripped.rfind('/') {
            (&stripped[..last_slash], &stripped[last_slash + 1..])
        } else {
            (stripped, "")
        }
    } else {
        // Plain string: RuboCop wraps in Regexp.new(), so treat as regex body
        (pattern, "")
    };

    if !regex_body.is_empty() {
        let mut compiled = String::new();
        if flags.contains('i') {
            compiled.push_str("(?i)");
        }
        compiled.push_str(regex_body);
        if let Ok(re) = regex::Regex::new(&compiled) {
            return re.is_match(delimiter);
        }
    }

    // Fallback: exact case-insensitive match (if regex compilation fails)
    delimiter.eq_ignore_ascii_case(pattern)
}

fn is_forbidden_delimiter(delimiter: &str, configured_patterns: Option<&Vec<String>>) -> bool {
    if let Some(patterns) = configured_patterns {
        for pattern in patterns {
            if delimiter_matches_pattern(delimiter, pattern) {
                return true;
            }
        }
        return false;
    }

    is_default_forbidden_delimiter(delimiter)
}

impl Cop for HeredocDelimiterNaming {
    fn name(&self) -> &'static str {
        "Naming/HeredocDelimiterNaming"
    }

    fn interested_node_types(&self) -> &'static [u8] {
        &[
            INTERPOLATED_STRING_NODE,
            STRING_NODE,
            INTERPOLATED_X_STRING_NODE,
            X_STRING_NODE,
        ]
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
        let forbidden_delimiters = config.get_string_array("ForbiddenDelimiters");

        // Check string and xstring nodes for heredoc openings.
        let (opening_loc, closing_start) = if let Some(interp) = node.as_interpolated_string_node()
        {
            (
                interp.opening_loc(),
                interp.closing_loc().map(|loc| loc.start_offset()),
            )
        } else if let Some(s) = node.as_string_node() {
            (
                s.opening_loc(),
                s.closing_loc().map(|loc| loc.start_offset()),
            )
        } else if let Some(x) = node.as_interpolated_x_string_node() {
            (Some(x.opening_loc()), Some(x.closing_loc().start_offset()))
        } else if let Some(x) = node.as_x_string_node() {
            (Some(x.opening_loc()), Some(x.closing_loc().start_offset()))
        } else {
            return;
        };

        let opening_loc = match opening_loc {
            Some(loc) => loc,
            None => return,
        };

        let bytes = source.as_bytes();
        let opening = &bytes[opening_loc.start_offset()..opening_loc.end_offset()];

        if !opening.starts_with(b"<<") {
            return;
        }

        // Extract delimiter.
        let after_arrows = &opening[2..];
        let after_prefix = if after_arrows.starts_with(b"~") || after_arrows.starts_with(b"-") {
            &after_arrows[1..]
        } else {
            after_arrows
        };

        let delimiter = if after_prefix.starts_with(b"'")
            || after_prefix.starts_with(b"\"")
            || after_prefix.starts_with(b"`")
        {
            let quote = after_prefix[0];
            let end = after_prefix[1..]
                .iter()
                .position(|&b| b == quote)
                .unwrap_or(after_prefix.len() - 1);
            &after_prefix[1..1 + end]
        } else {
            let end = after_prefix
                .iter()
                .position(|b| !b.is_ascii_alphanumeric() && *b != b'_')
                .unwrap_or(after_prefix.len());
            if end == 0 {
                &after_prefix[..1]
            } else {
                &after_prefix[..end]
            }
        };

        let delimiter_str = std::str::from_utf8(delimiter).unwrap_or("");
        if delimiter_str.is_empty() {
            return;
        }

        // RuboCop flags the closing delimiter token.
        if !contains_word_char(delimiter_str)
            || is_forbidden_delimiter(delimiter_str, forbidden_delimiters.as_ref())
        {
            let offense_offset = closing_start.unwrap_or(opening_loc.start_offset() + 2);
            let (line, column) = source.offset_to_line_col(offense_offset);
            diagnostics.push(self.diagnostic(
                source,
                line,
                column,
                "Use meaningful heredoc delimiters.".to_string(),
            ));
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    crate::cop_fixture_tests!(
        HeredocDelimiterNaming,
        "cops/naming/heredoc_delimiter_naming"
    );
}
