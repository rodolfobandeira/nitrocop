use crate::cop::{Cop, CopConfig};
use crate::diagnostic::Diagnostic;
use crate::parse::source::SourceFile;

/// ## Corpus investigation (2026-03-10)
///
/// CI baseline reported FP=6, FN=108.
///
/// Fixed a confirmed behavior gap in the local and vendor coverage: the
/// trailing scan previously handled only ASCII spaces and tabs. It now also
/// recognizes UTF-8 full-width spaces (`U+3000`) and strips a line-ending `\r`
/// before computing the trailing span so diagnostics and autocorrect stay
/// aligned on CRLF input.
///
/// Sampled corpus `# ` comment lines were consistent with existing file-drop
/// noise and did not justify a broader comment-specific change, so the
/// accepted patch stayed narrow.
///
/// Acceptance gate after this patch (`scripts/check-cop.py --verbose --rerun`):
/// expected=73,221, actual=71,636, CI baseline=73,119, excess=0, missing=1,585,
/// file-drop noise=1,014.
///
/// Remaining gap: 1,585 potential FN remain. This batch only fixed the
/// Unicode/offset handling path; the remaining misses were not reduced further.
pub struct TrailingWhitespace;

fn strip_line_ending_carriage_return(line: &[u8]) -> &[u8] {
    line.strip_suffix(b"\r").unwrap_or(line)
}

fn trailing_whitespace_start(line: &[u8]) -> Option<usize> {
    let mut end = line.len();
    let mut found = false;

    while end > 0 {
        if matches!(line[end - 1], b' ' | b'\t') {
            end -= 1;
            found = true;
            continue;
        }

        if end >= 3 && line[end - 3..end] == [0xE3, 0x80, 0x80] {
            end -= 3;
            found = true;
            continue;
        }

        break;
    }

    found.then_some(end)
}

impl Cop for TrailingWhitespace {
    fn name(&self) -> &'static str {
        "Layout/TrailingWhitespace"
    }

    fn supports_autocorrect(&self) -> bool {
        true
    }

    fn check_lines(
        &self,
        source: &SourceFile,
        config: &CopConfig,
        diagnostics: &mut Vec<Diagnostic>,
        mut corrections: Option<&mut Vec<crate::correction::Correction>>,
    ) {
        let allow_in_heredoc = config.get_bool("AllowInHeredoc", false);

        // Track heredoc regions: when AllowInHeredoc is true, skip lines inside heredocs.
        // Simple heuristic: track <<~WORD / <<-WORD / <<WORD openers and their terminators.
        let lines: Vec<&[u8]> = source.lines().collect();
        let mut heredoc_terminator: Option<Vec<u8>> = None;

        for (i, line) in lines.iter().enumerate() {
            // Stop checking after __END__ marker (data section)
            if *line == b"__END__" {
                break;
            }

            // Check if we're inside a heredoc
            if let Some(ref terminator) = heredoc_terminator {
                let trimmed: Vec<u8> = line
                    .iter()
                    .copied()
                    .skip_while(|&b| b == b' ' || b == b'\t')
                    .collect();
                if trimmed == *terminator
                    || trimmed.strip_suffix(b"\r").unwrap_or(&trimmed) == terminator.as_slice()
                {
                    heredoc_terminator = None;
                } else if allow_in_heredoc {
                    continue; // Skip trailing whitespace check inside heredoc
                }
            }

            // Detect heredoc openers (<<~WORD, <<-WORD, <<WORD, <<~'WORD', etc.)
            if heredoc_terminator.is_none() {
                if let Some(pos) = line.windows(2).position(|w| w == b"<<") {
                    let after = &line[pos + 2..];
                    let after = if after.starts_with(b"~") || after.starts_with(b"-") {
                        &after[1..]
                    } else {
                        after
                    };
                    // Strip quotes around terminator
                    let (after, _quoted) = if after.starts_with(b"'") || after.starts_with(b"\"") {
                        let quote = after[0];
                        if let Some(end) = after[1..].iter().position(|&b| b == quote) {
                            (&after[1..1 + end], true)
                        } else {
                            (after, false)
                        }
                    } else {
                        (after, false)
                    };
                    // Extract identifier
                    let ident: Vec<u8> = after
                        .iter()
                        .copied()
                        .take_while(|&b| b.is_ascii_alphanumeric() || b == b'_')
                        .collect();
                    if !ident.is_empty() {
                        heredoc_terminator = Some(ident);
                    }
                }
            }

            let line = strip_line_ending_carriage_return(line);
            if line.is_empty() {
                continue;
            }
            if let Some(trailing_start) = trailing_whitespace_start(line) {
                let Some(line_start) = source.line_col_to_offset(i + 1, 0) else {
                    continue;
                };
                let start = line_start + trailing_start;
                let end = line_start + line.len();
                let (line_num, column) = source.offset_to_line_col(start);
                let mut diag = self.diagnostic(
                    source,
                    line_num,
                    column,
                    "Trailing whitespace detected.".to_string(),
                );
                if let Some(ref mut corr) = corrections {
                    corr.push(crate::correction::Correction {
                        start,
                        end,
                        replacement: String::new(),
                        cop_name: self.name(),
                        cop_index: 0,
                    });
                    diag.corrected = true;
                }
                diagnostics.push(diag);
            }
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    crate::cop_fixture_tests!(TrailingWhitespace, "cops/layout/trailing_whitespace");
    crate::cop_autocorrect_fixture_tests!(TrailingWhitespace, "cops/layout/trailing_whitespace");

    #[test]
    fn no_offense_after_end_marker() {
        let source = SourceFile::from_bytes(
            "test.rb",
            b"x = 1\n__END__\ndata with trailing spaces   \nmore data   \n".to_vec(),
        );
        let mut diags = Vec::new();
        TrailingWhitespace.check_lines(&source, &CopConfig::default(), &mut diags, None);
        assert!(
            diags.is_empty(),
            "Should not flag trailing whitespace after __END__"
        );
    }

    #[test]
    fn all_whitespace_line() {
        let source = SourceFile::from_bytes("test.rb", b"x = 1\n   \ny = 2\n".to_vec());
        let mut diags = Vec::new();
        TrailingWhitespace.check_lines(&source, &CopConfig::default(), &mut diags, None);
        assert_eq!(diags.len(), 1);
        assert_eq!(diags[0].location.line, 2);
        assert_eq!(diags[0].location.column, 0);
    }

    #[test]
    fn trailing_tab() {
        let source = SourceFile::from_bytes("test.rb", b"x = 1\t\n".to_vec());
        let mut diags = Vec::new();
        TrailingWhitespace.check_lines(&source, &CopConfig::default(), &mut diags, None);
        assert_eq!(diags.len(), 1);
        assert_eq!(diags[0].location.line, 1);
        assert_eq!(diags[0].location.column, 5);
    }

    #[test]
    fn no_trailing_newline() {
        let source = SourceFile::from_bytes("test.rb", b"x = 1  ".to_vec());
        let mut diags = Vec::new();
        TrailingWhitespace.check_lines(&source, &CopConfig::default(), &mut diags, None);
        assert_eq!(diags.len(), 1);
        assert_eq!(diags[0].location.line, 1);
        assert_eq!(diags[0].location.column, 5);
    }

    #[test]
    fn allow_in_heredoc_skips_heredoc_whitespace() {
        use std::collections::HashMap;
        let config = CopConfig {
            options: HashMap::from([("AllowInHeredoc".into(), serde_yml::Value::Bool(true))]),
            ..CopConfig::default()
        };
        let source = SourceFile::from_bytes(
            "test.rb",
            b"x = <<~TEXT\n  hello  \n  world  \nTEXT\n".to_vec(),
        );
        let mut diags = Vec::new();
        TrailingWhitespace.check_lines(&source, &config, &mut diags, None);
        assert!(
            diags.is_empty(),
            "AllowInHeredoc should skip trailing whitespace inside heredocs"
        );
    }

    #[test]
    fn default_flags_heredoc_whitespace() {
        let source = SourceFile::from_bytes("test.rb", b"x = <<~TEXT\n  hello  \nTEXT\n".to_vec());
        let mut diags = Vec::new();
        TrailingWhitespace.check_lines(&source, &CopConfig::default(), &mut diags, None);
        assert_eq!(
            diags.len(),
            1,
            "Default should flag trailing whitespace inside heredocs"
        );
    }

    #[test]
    fn autocorrect_trailing_spaces() {
        let input = b"x = 1   \ny = 2\n";
        let (diags, corrections) = crate::testutil::run_cop_autocorrect(&TrailingWhitespace, input);
        assert_eq!(diags.len(), 1);
        assert!(diags[0].corrected);
        let cs = crate::correction::CorrectionSet::from_vec(corrections);
        let corrected = cs.apply(input);
        assert_eq!(corrected, b"x = 1\ny = 2\n");
    }

    #[test]
    fn autocorrect_all_whitespace_line() {
        let input = b"x = 1\n   \ny = 2\n";
        let (diags, corrections) = crate::testutil::run_cop_autocorrect(&TrailingWhitespace, input);
        assert_eq!(diags.len(), 1);
        assert!(diags[0].corrected);
        let cs = crate::correction::CorrectionSet::from_vec(corrections);
        let corrected = cs.apply(input);
        assert_eq!(corrected, b"x = 1\n\ny = 2\n");
    }

    #[test]
    fn autocorrect_multiple_lines() {
        let input = b"x = 1  \ny = 2  \nz = 3\n";
        let (diags, corrections) = crate::testutil::run_cop_autocorrect(&TrailingWhitespace, input);
        assert_eq!(diags.len(), 2);
        assert!(diags.iter().all(|d| d.corrected));
        let cs = crate::correction::CorrectionSet::from_vec(corrections);
        let corrected = cs.apply(input);
        assert_eq!(corrected, b"x = 1\ny = 2\nz = 3\n");
    }

    #[test]
    fn autocorrect_no_trailing_newline() {
        let input = b"x = 1  ";
        let (diags, corrections) = crate::testutil::run_cop_autocorrect(&TrailingWhitespace, input);
        assert_eq!(diags.len(), 1);
        assert!(diags[0].corrected);
        let cs = crate::correction::CorrectionSet::from_vec(corrections);
        let corrected = cs.apply(input);
        assert_eq!(corrected, b"x = 1");
    }
}
