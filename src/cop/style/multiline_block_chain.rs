use crate::cop::{Cop, CopConfig};
use crate::diagnostic::{Diagnostic, Location, Severity};
use crate::parse::source::SourceFile;
use ruby_prism::Visit;

/// Detects chaining of a block after another block that spans multiple lines.
///
/// Investigation notes:
/// - RuboCop triggers `on_block`, then walks `node.send_node.each_node(:call)` to find
///   a call whose receiver is a multiline block. It reports from the receiver block's
///   `end`/`}` keyword to the end of the outer block's send node (e.g., `end.map`).
/// - Original nitrocop had two bugs:
///   1. Only checked the direct receiver for a block, missing intermediate method chains
///      like `end.c1.c2 do` where `.c1` has no block but its receiver does.
///   2. Reported at the method name location (e.g., `map`) instead of from the block's
///      closing delimiter (`end` or `}`) to the method name (e.g., `end.map`).
/// - The near-equal FP/FN counts in corpus repos (e.g., oga 39 FP / 40 FN) confirmed
///   a location mismatch: same chains detected but reported on different lines/columns.
pub struct MultilineBlockChain;

/// Visitor that checks for multiline block chains.
/// RuboCop triggers on_block, then walks send_node.each_node(:call) looking for
/// a call whose receiver is a multiline block. We replicate this by visiting
/// CallNodes that have blocks and walking the receiver chain to find a
/// multiline block receiver (possibly through intermediate method calls).
struct BlockChainVisitor<'a> {
    source: &'a SourceFile,
    cop_name: &'static str,
    diagnostics: Vec<Diagnostic>,
}

impl<'pr> Visit<'pr> for BlockChainVisitor<'_> {
    fn visit_call_node(&mut self, node: &ruby_prism::CallNode<'pr>) {
        // Only check calls that have a real block (do..end or {..}).
        // This matches RuboCop's on_block trigger — only block-to-block chains.
        let has_block = if let Some(block) = node.block() {
            block.as_block_node().is_some()
        } else {
            false
        };

        if has_block {
            // Walk the receiver chain looking for a call with a multiline block
            self.check_receiver_chain(node);
        }

        // Continue traversal into children
        ruby_prism::visit_call_node(self, node);
    }
}

impl BlockChainVisitor<'_> {
    /// Walk the receiver chain of a call-with-block, looking for a multiline block.
    ///
    /// RuboCop does `node.send_node.each_node(:call)` which walks all call nodes
    /// in the send chain. For `end.c1.c2 do ... end`, the send node chain is:
    /// `.c2` -> `.c1` -> (block receiver). We follow CallNode receivers until we
    /// find one with a multiline block, or run out of calls.
    fn check_receiver_chain(&mut self, node: &ruby_prism::CallNode<'_>) {
        // Walk the receiver chain: node -> receiver -> receiver's receiver -> ...
        // At each step, if the current call has a multiline block receiver, report.
        let mut current = match node.receiver() {
            Some(r) => r,
            None => return,
        };

        loop {
            let call = match current.as_call_node() {
                Some(c) => c,
                None => return,
            };

            // Does this call have a real block (do..end or {..})?
            if let Some(block_arg) = call.block() {
                if let Some(block_node) = block_arg.as_block_node() {
                    // Is the block multiline?
                    let block_loc = block_node.location();
                    let (block_start, _) = self.source.offset_to_line_col(block_loc.start_offset());
                    let (block_end, _) = self
                        .source
                        .offset_to_line_col(block_loc.end_offset().saturating_sub(1));

                    if block_start != block_end {
                        // Found a multiline block in the receiver chain.
                        // Report from the block's closing delimiter to the end of
                        // the outermost send node's method name.
                        // RuboCop: range_between(receiver.loc.end.begin_pos,
                        //                        node.send_node.source_range.end_pos)
                        let closing_loc = block_node.closing_loc();
                        let (line, column) =
                            self.source.offset_to_line_col(closing_loc.start_offset());

                        self.diagnostics.push(Diagnostic {
                            path: self.source.path_str().to_string(),
                            location: Location { line, column },
                            severity: Severity::Convention,
                            cop_name: self.cop_name.to_string(),
                            message: "Avoid multi-line chains of blocks.".to_string(),
                            corrected: false,
                        });
                        return;
                    }
                }
            }

            // Continue walking up the receiver chain
            current = match call.receiver() {
                Some(r) => r,
                None => return,
            };
        }
    }
}

impl Cop for MultilineBlockChain {
    fn name(&self) -> &'static str {
        "Style/MultilineBlockChain"
    }

    fn check_source(
        &self,
        source: &SourceFile,
        parse_result: &ruby_prism::ParseResult<'_>,
        _code_map: &crate::parse::codemap::CodeMap,
        _config: &CopConfig,
        diagnostics: &mut Vec<Diagnostic>,
        _corrections: Option<&mut Vec<crate::correction::Correction>>,
    ) {
        let mut visitor = BlockChainVisitor {
            source,
            cop_name: self.name(),
            diagnostics: Vec::new(),
        };
        visitor.visit(&parse_result.node());
        diagnostics.extend(visitor.diagnostics);
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    crate::cop_fixture_tests!(MultilineBlockChain, "cops/style/multiline_block_chain");
}
