use crate::cop::util;
use crate::cop::{Cop, CopConfig};
use crate::diagnostic::Diagnostic;
use crate::parse::codemap::CodeMap;
use crate::parse::source::SourceFile;

/// ## Corpus investigation (2026-03-10)
///
/// Cached corpus oracle reported FP=8, FN=2.
///
/// Fixed FN=2: compact `rescue=>e` headers were previously skipped because the
/// line matcher only accepted whitespace after `rescue`. The accepted fix
/// special-cases `rescue=>` without broadening `else`/`ensure` matching.
///
/// Fixed FP: blank lines after single-line exception clauses such as
/// `rescue NameError; nil end` should be ignored because the `rescue` and `end`
/// share a line. The source scan now skips the "blank line after" check when
/// the same line also contains a standalone `end`.
///
/// A broader boundary matcher for all keywords reintroduced the historical
/// zero-baseline regression on `cerebris__jsonapi-resources__e92afc6`, so the
/// accepted version keeps the compact-syntax exception rescue-only.
///
/// Acceptance gate after this patch (`scripts/check-cop.py --verbose --rerun`):
/// expected=537, actual=580, CI baseline=543, raw excess=43, missing=0,
/// file-drop noise=37. The rerun passes against the CI baseline once that
/// existing noise is applied.
pub struct EmptyLinesAroundExceptionHandlingKeywords;

const KEYWORDS: &[&[u8]] = &[b"rescue", b"ensure", b"else"];

/// Check if an `else` on this line is part of a rescue block (not if/case/etc.).
/// Scan backwards from the `else` to find whether we hit `rescue` (rescue-else)
/// or `if`/`unless`/`case`/`when`/`elsif` (regular else) at the same indentation.
fn is_rescue_else(lines: &[&[u8]], else_idx: usize, else_indent: usize) -> bool {
    for i in (0..else_idx).rev() {
        let line = lines[i];
        let start = match line.iter().position(|&b| b != b' ' && b != b'\t') {
            Some(p) => p,
            None => continue,
        };
        let content = &line[start..];
        // Only consider lines at the same or less indentation
        if start > else_indent {
            continue;
        }
        // Check for rescue at the same indent
        if start == else_indent && starts_with_kw(content, b"rescue") {
            return true;
        }
        // If we hit a structural keyword at the same or less indentation, it's not rescue-else
        if starts_with_kw(content, b"if")
            || starts_with_kw(content, b"unless")
            || starts_with_kw(content, b"case")
            || starts_with_kw(content, b"when")
            || starts_with_kw(content, b"elsif")
        {
            return false;
        }
        // def/begin/class/module at same or less indent = scope boundary, check if rescue exists
        if starts_with_kw(content, b"def")
            || starts_with_kw(content, b"begin")
            || starts_with_kw(content, b"class")
            || starts_with_kw(content, b"module")
        {
            return false;
        }
    }
    false
}

fn starts_with_kw(content: &[u8], kw: &[u8]) -> bool {
    content.starts_with(kw)
        && (content.len() == kw.len()
            || !content[kw.len()].is_ascii_alphanumeric() && content[kw.len()] != b'_')
}

fn matches_keyword_line(content: &[u8], kw: &[u8]) -> bool {
    if !content.starts_with(kw) {
        return false;
    }

    let Some(rest) = content.get(kw.len()..) else {
        return true;
    };

    rest.is_empty()
        || matches!(rest[0], b' ' | b'\t' | b'\n' | b'\r')
        || (kw == b"rescue" && rest.starts_with(b"=>"))
}

fn has_inline_end(content: &[u8], keyword: &[u8]) -> bool {
    let Some(rest) = content.get(keyword.len()..) else {
        return false;
    };

    for idx in 0..rest.len() {
        if starts_with_kw(&rest[idx..], b"end") {
            return true;
        }
    }

    false
}

impl Cop for EmptyLinesAroundExceptionHandlingKeywords {
    fn name(&self) -> &'static str {
        "Layout/EmptyLinesAroundExceptionHandlingKeywords"
    }

    fn supports_autocorrect(&self) -> bool {
        true
    }

    fn check_source(
        &self,
        source: &SourceFile,
        _parse_result: &ruby_prism::ParseResult<'_>,
        code_map: &CodeMap,
        _config: &CopConfig,
        diagnostics: &mut Vec<Diagnostic>,
        mut corrections: Option<&mut Vec<crate::correction::Correction>>,
    ) {
        let lines: Vec<&[u8]> = source.lines().collect();
        let mut byte_offset: usize = 0;

        for (i, line) in lines.iter().enumerate() {
            let line_len = line.len() + 1; // +1 for newline
            let line_num = i + 1;
            let trimmed_start = match line.iter().position(|&b| b != b' ' && b != b'\t') {
                Some(p) => p,
                None => {
                    byte_offset += line_len;
                    continue;
                }
            };
            let content = &line[trimmed_start..];

            // Check if this line is a rescue/ensure/else keyword at the start of a line
            let matched_keyword = KEYWORDS
                .iter()
                .find(|&&kw| matches_keyword_line(content, kw));

            let keyword = match matched_keyword {
                Some(kw) => *kw,
                None => {
                    byte_offset += line_len;
                    continue;
                }
            };

            // Skip keywords inside strings/heredocs/regexps/symbols
            if !code_map.is_not_string(byte_offset + trimmed_start) {
                byte_offset += line_len;
                continue;
            }

            // For `else`, only flag if it's part of a rescue block (not if/case/etc.)
            if keyword == b"else" && !is_rescue_else(&lines, i, trimmed_start) {
                byte_offset += line_len;
                continue;
            }

            let kw_str = std::str::from_utf8(keyword).unwrap_or("rescue");

            // Check for empty line BEFORE the keyword
            if line_num >= 3 {
                let above_idx = i - 1; // 0-indexed
                if above_idx < lines.len() && util::is_blank_line(lines[above_idx]) {
                    let mut diag = self.diagnostic(
                        source,
                        line_num - 1,
                        0,
                        format!("Extra empty line detected before the `{kw_str}`."),
                    );
                    if let Some(ref mut corr) = corrections {
                        // Delete the blank line (line_num - 1 is 1-based)
                        if let (Some(start), Some(end)) = (
                            source.line_col_to_offset(line_num - 1, 0),
                            source.line_col_to_offset(line_num, 0),
                        ) {
                            corr.push(crate::correction::Correction {
                                start,
                                end,
                                replacement: String::new(),
                                cop_name: self.name(),
                                cop_index: 0,
                            });
                            diag.corrected = true;
                        }
                    }
                    diagnostics.push(diag);
                }
            }

            // Check for empty line AFTER the keyword
            let below_idx = i + 1; // 0-indexed for line after
            if has_inline_end(content, keyword) {
                byte_offset += line_len;
                continue;
            }

            if below_idx < lines.len() && util::is_blank_line(lines[below_idx]) {
                let mut diag = self.diagnostic(
                    source,
                    line_num + 1,
                    0,
                    format!("Extra empty line detected after the `{kw_str}`."),
                );
                if let Some(ref mut corr) = corrections {
                    // Delete the blank line (line_num + 1 is 1-based)
                    if let (Some(start), Some(end)) = (
                        source.line_col_to_offset(line_num + 1, 0),
                        source.line_col_to_offset(line_num + 2, 0),
                    ) {
                        corr.push(crate::correction::Correction {
                            start,
                            end,
                            replacement: String::new(),
                            cop_name: self.name(),
                            cop_index: 0,
                        });
                        diag.corrected = true;
                    }
                }
                diagnostics.push(diag);
            }

            byte_offset += line_len;
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::testutil::run_cop_full;

    crate::cop_fixture_tests!(
        EmptyLinesAroundExceptionHandlingKeywords,
        "cops/layout/empty_lines_around_exception_handling_keywords"
    );
    crate::cop_autocorrect_fixture_tests!(
        EmptyLinesAroundExceptionHandlingKeywords,
        "cops/layout/empty_lines_around_exception_handling_keywords"
    );

    #[test]
    fn skip_keywords_in_heredoc() {
        let source =
            b"x = <<~RUBY\n  begin\n    something\n\n  rescue\n\n    handle\n  end\nRUBY\n";
        let diags = run_cop_full(&EmptyLinesAroundExceptionHandlingKeywords, source);
        assert!(
            diags.is_empty(),
            "Should not fire on rescue inside heredoc, got: {:?}",
            diags
        );
    }

    #[test]
    fn skip_keywords_in_string() {
        let source = b"x = \"rescue\"\ny = 'ensure'\n";
        let diags = run_cop_full(&EmptyLinesAroundExceptionHandlingKeywords, source);
        assert!(
            diags.is_empty(),
            "Should not fire on keywords inside strings"
        );
    }
}
