use crate::cop::node_type::DEF_NODE;
use crate::cop::util;
use crate::cop::{Cop, CopConfig};
use crate::diagnostic::Diagnostic;
use crate::parse::source::SourceFile;

/// Layout/EmptyLinesAroundMethodBody
///
/// Flags extra empty lines at the beginning/end of a method body.
///
/// Root causes of historical FP/FN:
/// - **FP (whitespace-only lines):** `is_blank_line()` treated lines with only
///   spaces/tabs as blank, but RuboCop only flags completely empty lines.
///   Fixed by tightening `is_blank_line()` in util.rs.
/// - **FN (multiline-arg defs):** keyword_offset was always `def` line, but for
///   `def foo(\n  arg\n)`, the body starts after `)`. Fixed by using
///   `rparen_loc` when present and on a different line than `def`.
/// - **FN (endless methods):** Endless methods (`def foo =`) were completely
///   skipped. RuboCop flags blank lines after `=` in multiline endless methods.
///   Fixed by using `equal_loc` as the keyword offset for endless methods.
pub struct EmptyLinesAroundMethodBody;

impl Cop for EmptyLinesAroundMethodBody {
    fn name(&self) -> &'static str {
        "Layout/EmptyLinesAroundMethodBody"
    }

    fn interested_node_types(&self) -> &'static [u8] {
        &[DEF_NODE]
    }

    fn supports_autocorrect(&self) -> bool {
        true
    }

    fn check_node(
        &self,
        source: &SourceFile,
        node: &ruby_prism::Node<'_>,
        _parse_result: &ruby_prism::ParseResult<'_>,
        _config: &CopConfig,
        diagnostics: &mut Vec<Diagnostic>,
        mut corrections: Option<&mut Vec<crate::correction::Correction>>,
    ) {
        let def_node = match node.as_def_node() {
            Some(d) => d,
            None => return,
        };

        if let Some(end_loc) = def_node.end_keyword_loc() {
            // Regular method (has `end` keyword)
            // For multiline-arg defs, use the closing `)` line as the keyword offset
            // so we check for blank lines after `)`, not after `def`.
            let keyword_offset = if let Some(rparen) = def_node.rparen_loc() {
                let (def_line, _) =
                    source.offset_to_line_col(def_node.def_keyword_loc().start_offset());
                let (rparen_line, _) = source.offset_to_line_col(rparen.start_offset());
                if rparen_line > def_line {
                    rparen.start_offset()
                } else {
                    def_node.def_keyword_loc().start_offset()
                }
            } else {
                def_node.def_keyword_loc().start_offset()
            };

            diagnostics.extend(util::check_empty_lines_around_body_with_corrections(
                self.name(),
                source,
                keyword_offset,
                end_loc.start_offset(),
                "method",
                corrections,
            ));
        } else if let Some(equal_loc) = def_node.equal_loc() {
            // Endless method (`def foo = expr`)
            // Only check for blank line after `=` (no `end` keyword, so no end check)
            let equal_offset = equal_loc.start_offset();
            let (equal_line, _) = source.offset_to_line_col(equal_offset);

            // Find the last line of the body to use as end boundary
            let body_end = def_node.location().end_offset();
            let (body_end_line, _) = source.offset_to_line_col(body_end);

            // Skip if everything is on the same line as `=`
            if body_end_line <= equal_line {
                return;
            }

            // Check for blank line after `=`
            let after_equal = equal_line + 1;
            if let Some(line) = util::line_at(source, after_equal) {
                if util::is_blank_line(line) && after_equal < body_end_line {
                    let mut diag = Diagnostic {
                        path: source.path_str().to_string(),
                        location: crate::diagnostic::Location {
                            line: after_equal,
                            column: 0,
                        },
                        severity: crate::diagnostic::Severity::Convention,
                        cop_name: self.name().to_string(),
                        message: "Extra empty line detected at method body beginning.".to_string(),
                        corrected: false,
                    };
                    if let Some(ref mut corr) = corrections {
                        if let (Some(start), Some(end)) = (
                            source.line_col_to_offset(after_equal, 0),
                            source.line_col_to_offset(after_equal + 1, 0),
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
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::testutil::run_cop_full;

    crate::cop_fixture_tests!(
        EmptyLinesAroundMethodBody,
        "cops/layout/empty_lines_around_method_body"
    );
    crate::cop_autocorrect_fixture_tests!(
        EmptyLinesAroundMethodBody,
        "cops/layout/empty_lines_around_method_body"
    );

    #[test]
    fn single_line_def_no_offense() {
        let src = b"def foo; 42; end\n";
        let diags = run_cop_full(&EmptyLinesAroundMethodBody, src);
        assert!(diags.is_empty(), "Single-line def should not trigger");
    }

    #[test]
    fn endless_method_no_offense() {
        let src = b"def foo = 42\n";
        let diags = run_cop_full(&EmptyLinesAroundMethodBody, src);
        assert!(diags.is_empty(), "Endless method should not trigger");
    }

    #[test]
    fn whitespace_only_line_no_offense() {
        // RuboCop does NOT flag lines with trailing whitespace — only truly empty lines.
        // Lines with spaces/tabs are handled by Layout/TrailingWhitespace.
        let src = b"def some_method\n  \n  do_something\nend\n";
        let diags = run_cop_full(&EmptyLinesAroundMethodBody, src);
        assert!(
            diags.is_empty(),
            "Whitespace-only line should not be flagged: {diags:?}"
        );
    }

    #[test]
    fn whitespace_only_line_at_end_no_offense() {
        let src = b"def some_method\n  do_something\n  \nend\n";
        let diags = run_cop_full(&EmptyLinesAroundMethodBody, src);
        assert!(
            diags.is_empty(),
            "Whitespace-only line at end should not be flagged: {diags:?}"
        );
    }

    #[test]
    fn multiline_arg_def_blank_after_rparen() {
        let src = b"def some_method(\n  arg\n)\n\n  do_something\nend\n";
        let diags = run_cop_full(&EmptyLinesAroundMethodBody, src);
        assert_eq!(diags.len(), 1, "Should flag blank line after ): {diags:?}");
        assert!(diags[0].message.contains("beginning"));
    }

    #[test]
    fn endless_method_multiline_blank_after_equal() {
        let src = b"def compute(value,\n  factor) =\n\n  value * factor\n";
        let diags = run_cop_full(&EmptyLinesAroundMethodBody, src);
        assert_eq!(
            diags.len(),
            1,
            "Should flag blank line after = in endless method: {diags:?}"
        );
        assert!(diags[0].message.contains("beginning"));
    }

    #[test]
    fn endless_method_no_blank_no_offense() {
        let src = b"def compute(value,\n  factor) =\n  value * factor\n";
        let diags = run_cop_full(&EmptyLinesAroundMethodBody, src);
        assert!(
            diags.is_empty(),
            "Endless method without blank should not trigger: {diags:?}"
        );
    }
}
