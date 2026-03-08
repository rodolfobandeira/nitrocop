use crate::cop::{Cop, CopConfig};
use crate::diagnostic::{Diagnostic, Severity};
use crate::parse::source::SourceFile;

/// Corpus investigation: 21 FPs on whitespace-only files.
/// Root cause: RuboCop's `empty_file?` checks `source.empty?` (0 bytes),
/// NOT whether the file contains only whitespace. Files with just newlines
/// or spaces are not flagged by RuboCop. The `contains_only_comments?`
/// check only runs when `AllowComments: false`.
/// Fix: only flag truly empty (0-byte) files, not whitespace-only files.
pub struct EmptyFile;

impl Cop for EmptyFile {
    fn name(&self) -> &'static str {
        "Lint/EmptyFile"
    }

    fn default_severity(&self) -> Severity {
        Severity::Warning
    }

    fn check_lines(
        &self,
        source: &SourceFile,
        config: &CopConfig,
        diagnostics: &mut Vec<Diagnostic>,
        _corrections: Option<&mut Vec<crate::correction::Correction>>,
    ) {
        let src = source.as_bytes();

        // RuboCop only flags truly empty files (0 bytes).
        // Whitespace-only files are NOT flagged.
        if src.is_empty() {
            diagnostics.push(self.diagnostic(source, 1, 0, "Empty file detected.".to_string()));
            return;
        }

        // When AllowComments is false, also flag files containing only comments/whitespace
        let allow_comments = config.get_bool("AllowComments", true);
        if !allow_comments {
            let has_code = source.lines().any(|line| {
                let trimmed = line
                    .iter()
                    .position(|&b| b != b' ' && b != b'\t' && b != b'\r')
                    .map(|start| &line[start..])
                    .unwrap_or(&[]);
                !trimmed.is_empty() && !trimmed.starts_with(b"#")
            });

            if !has_code {
                diagnostics.push(self.diagnostic(source, 1, 0, "Empty file detected.".to_string()));
            }
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    crate::cop_scenario_fixture_tests!(
        EmptyFile,
        "cops/lint/empty_file",
        empty_file = "empty.rb",
        empty_no_newline = "empty_no_newline.rb",
        empty_crlf = "empty_crlf.rb",
    );
}
