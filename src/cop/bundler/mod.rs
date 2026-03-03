pub mod duplicated_gem;
pub mod duplicated_group;
pub mod gem_comment;
pub mod gem_filename;
pub mod gem_version;
pub mod insecure_protocol_source;
pub mod ordered_gems;

use super::registry::CopRegistry;

pub fn register_all(registry: &mut CopRegistry) {
    registry.register(Box::new(duplicated_gem::DuplicatedGem));
    registry.register(Box::new(duplicated_group::DuplicatedGroup));
    registry.register(Box::new(gem_comment::GemComment));
    registry.register(Box::new(gem_filename::GemFilename));
    registry.register(Box::new(gem_version::GemVersion));
    registry.register(Box::new(insecure_protocol_source::InsecureProtocolSource));
    registry.register(Box::new(ordered_gems::OrderedGems));
}

/// Extract the gem name from a line like `gem 'foo'` or `gem "foo"` or `gem('foo')`.
/// Returns Some(gem_name) if the line is a gem declaration, None otherwise.
/// Rejects non-literal gem names (variables, method calls, interpolation).
pub fn extract_gem_name(line: &str) -> Option<&str> {
    let trimmed = line.trim();
    let after_gem = trimmed
        .strip_prefix("gem ")
        .or_else(|| trimmed.strip_prefix("gem("))?;
    // The first non-whitespace character after `gem ` or `gem(` must be a quote
    let first_non_ws = after_gem.trim_start();
    if !first_non_ws.starts_with('\'') && !first_non_ws.starts_with('"') {
        return None;
    }
    let quote_char = first_non_ws.as_bytes()[0];
    let rest = &first_non_ws[1..];
    let quote_end = rest.find(|c: char| c as u8 == quote_char)?;
    let name = &rest[..quote_end];
    // Reject interpolated strings like "social_stream-#{ g }"
    if name.contains("#{") {
        return None;
    }
    Some(name)
}
