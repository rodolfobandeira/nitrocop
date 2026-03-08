use crate::cop::node_type::{
    CLASS_VARIABLE_WRITE_NODE, DEF_NODE, GLOBAL_VARIABLE_WRITE_NODE, INSTANCE_VARIABLE_WRITE_NODE,
    LOCAL_VARIABLE_WRITE_NODE,
};
use crate::cop::util::is_snake_case;
use crate::cop::{Cop, CopConfig};
use crate::diagnostic::Diagnostic;
use crate::parse::source::SourceFile;

/// ## Corpus investigation (2026-03-08)
///
/// Corpus oracle reported FP=0, FN=2,911.
///
/// FN=2,911: nitrocop only checked LocalVariableWriteNode but RuboCop
/// checks all variable types (ivar, cvar, gvar) and method parameters.
/// Fixed by adding InstanceVariableWriteNode, ClassVariableWriteNode,
/// GlobalVariableWriteNode, and DefNode (for parameters) handling.
/// Also fixed AllowedPatterns to use regex matching instead of substring.
pub struct VariableName;

impl Cop for VariableName {
    fn name(&self) -> &'static str {
        "Naming/VariableName"
    }

    fn interested_node_types(&self) -> &'static [u8] {
        &[
            LOCAL_VARIABLE_WRITE_NODE,
            INSTANCE_VARIABLE_WRITE_NODE,
            CLASS_VARIABLE_WRITE_NODE,
            GLOBAL_VARIABLE_WRITE_NODE,
            DEF_NODE,
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
        // Handle DefNode for method parameters
        if let Some(def_node) = node.as_def_node() {
            self.check_parameters(source, def_node, config, diagnostics);
            return;
        }

        // Extract variable name and location based on node type
        let (raw_name, start_offset) = if let Some(n) = node.as_local_variable_write_node() {
            (n.name().as_slice(), n.name_loc().start_offset())
        } else if let Some(n) = node.as_instance_variable_write_node() {
            (n.name().as_slice(), n.name_loc().start_offset())
        } else if let Some(n) = node.as_class_variable_write_node() {
            (n.name().as_slice(), n.name_loc().start_offset())
        } else if let Some(n) = node.as_global_variable_write_node() {
            (n.name().as_slice(), n.name_loc().start_offset())
        } else {
            return;
        };

        let raw_name_str = std::str::from_utf8(raw_name).unwrap_or("");

        // Strip prefixes to get the bare variable name for style checking
        let var_name_str = raw_name_str
            .strip_prefix("@@")
            .or_else(|| raw_name_str.strip_prefix('@'))
            .or_else(|| raw_name_str.strip_prefix('$'))
            .unwrap_or(raw_name_str);

        // Skip special globals ($_, $0, $1, $!, $@, etc.)
        if raw_name_str.starts_with('$')
            && (var_name_str.is_empty()
                || var_name_str == "_"
                || var_name_str.starts_with(|c: char| c.is_ascii_digit())
                || (var_name_str.len() == 1 && !var_name_str.as_bytes()[0].is_ascii_alphabetic()))
        {
            return;
        }

        // Skip names starting with _ (convention for unused vars)
        if var_name_str.starts_with('_') {
            return;
        }

        let (line, column) = source.offset_to_line_col(start_offset);

        self.check_variable_name(source, var_name_str, line, column, config, diagnostics);
    }
}

impl VariableName {
    fn check_variable_name(
        &self,
        source: &SourceFile,
        var_name_str: &str,
        line: usize,
        column: usize,
        config: &CopConfig,
        diagnostics: &mut Vec<Diagnostic>,
    ) {
        let enforced_style = config.get_str("EnforcedStyle", "snake_case");
        let allowed_identifiers = config.get_string_array("AllowedIdentifiers");
        let allowed_patterns = config.get_string_array("AllowedPatterns");
        let forbidden_identifiers = config.get_string_array("ForbiddenIdentifiers");
        let forbidden_patterns = config.get_string_array("ForbiddenPatterns");

        // ForbiddenIdentifiers: flag if var name is in the forbidden list
        if let Some(forbidden) = &forbidden_identifiers {
            if forbidden.iter().any(|f| f == var_name_str) {
                diagnostics.push(self.diagnostic(
                    source,
                    line,
                    column,
                    format!("`{var_name_str}` is forbidden, use another variable name instead."),
                ));
            }
        }

        // ForbiddenPatterns: flag if var name matches any forbidden regex
        if let Some(patterns) = &forbidden_patterns {
            for pattern in patterns {
                if let Ok(re) = regex::Regex::new(pattern) {
                    if re.is_match(var_name_str) {
                        diagnostics.push(self.diagnostic(
                            source,
                            line,
                            column,
                            format!(
                                "`{var_name_str}` is forbidden, use another variable name instead."
                            ),
                        ));
                    }
                }
            }
        }

        // AllowedIdentifiers: skip if var name is explicitly allowed
        if let Some(allowed) = &allowed_identifiers {
            if allowed.iter().any(|a| a == var_name_str) {
                return;
            }
        }

        // AllowedPatterns: skip if var name matches any regex pattern
        if let Some(patterns) = &allowed_patterns {
            for p in patterns {
                if let Ok(re) = regex::Regex::new(p) {
                    if re.is_match(var_name_str) {
                        return;
                    }
                }
            }
        }

        // Check naming style
        let var_name = var_name_str.as_bytes();
        let style_ok = match enforced_style {
            "camelCase" => is_lower_camel_case(var_name),
            _ => is_snake_case(var_name), // snake_case is default
        };

        if style_ok {
            return;
        }

        let style_msg = match enforced_style {
            "camelCase" => "camelCase",
            _ => "snake_case",
        };

        diagnostics.push(self.diagnostic(
            source,
            line,
            column,
            format!("Use {style_msg} for variable names."),
        ));
    }

    fn check_parameters(
        &self,
        source: &SourceFile,
        def_node: ruby_prism::DefNode<'_>,
        config: &CopConfig,
        diagnostics: &mut Vec<Diagnostic>,
    ) {
        let params = match def_node.parameters() {
            Some(p) => p,
            None => return,
        };

        // Check required parameters
        for param in params.requireds().iter() {
            if let Some(req) = param.as_required_parameter_node() {
                let name = req.name().as_slice();
                let name_str = std::str::from_utf8(name).unwrap_or("");
                let (line, column) = source.offset_to_line_col(req.location().start_offset());
                if !name_str.starts_with('_') {
                    self.check_variable_name(source, name_str, line, column, config, diagnostics);
                }
            }
        }

        // Check optional parameters
        for param in params.optionals().iter() {
            if let Some(opt) = param.as_optional_parameter_node() {
                let name = opt.name().as_slice();
                let name_str = std::str::from_utf8(name).unwrap_or("");
                let (line, column) = source.offset_to_line_col(opt.name_loc().start_offset());
                if !name_str.starts_with('_') {
                    self.check_variable_name(source, name_str, line, column, config, diagnostics);
                }
            }
        }

        // Check keyword parameters
        for param in params.keywords().iter() {
            if let Some(kw) = param.as_required_keyword_parameter_node() {
                let name = kw.name().as_slice();
                let name_str = std::str::from_utf8(name).unwrap_or("");
                // Strip trailing : from keyword name
                let clean_name = name_str.strip_suffix(':').unwrap_or(name_str);
                let (line, column) = source.offset_to_line_col(kw.name_loc().start_offset());
                if !clean_name.starts_with('_') {
                    self.check_variable_name(source, clean_name, line, column, config, diagnostics);
                }
            }
            if let Some(kw) = param.as_optional_keyword_parameter_node() {
                let name = kw.name().as_slice();
                let name_str = std::str::from_utf8(name).unwrap_or("");
                let clean_name = name_str.strip_suffix(':').unwrap_or(name_str);
                let (line, column) = source.offset_to_line_col(kw.name_loc().start_offset());
                if !clean_name.starts_with('_') {
                    self.check_variable_name(source, clean_name, line, column, config, diagnostics);
                }
            }
        }

        // Check rest parameter (*args)
        if let Some(rest) = params.rest() {
            if let Some(rest_param) = rest.as_rest_parameter_node() {
                if let Some(name) = rest_param.name() {
                    let name_str = std::str::from_utf8(name.as_slice()).unwrap_or("");
                    if let Some(name_loc) = rest_param.name_loc() {
                        let (line, column) = source.offset_to_line_col(name_loc.start_offset());
                        if !name_str.starts_with('_') {
                            self.check_variable_name(
                                source,
                                name_str,
                                line,
                                column,
                                config,
                                diagnostics,
                            );
                        }
                    }
                }
            }
        }

        // Check keyword rest parameter (**kwargs)
        if let Some(kw_rest) = params.keyword_rest() {
            if let Some(kw_rest_param) = kw_rest.as_keyword_rest_parameter_node() {
                if let Some(name) = kw_rest_param.name() {
                    let name_str = std::str::from_utf8(name.as_slice()).unwrap_or("");
                    if let Some(name_loc) = kw_rest_param.name_loc() {
                        let (line, column) = source.offset_to_line_col(name_loc.start_offset());
                        if !name_str.starts_with('_') {
                            self.check_variable_name(
                                source,
                                name_str,
                                line,
                                column,
                                config,
                                diagnostics,
                            );
                        }
                    }
                }
            }
        }

        // Check block parameter (&block)
        if let Some(block) = params.block() {
            if let Some(name) = block.name() {
                let name_str = std::str::from_utf8(name.as_slice()).unwrap_or("");
                if let Some(name_loc) = block.name_loc() {
                    let (line, column) = source.offset_to_line_col(name_loc.start_offset());
                    if !name_str.starts_with('_') {
                        self.check_variable_name(
                            source,
                            name_str,
                            line,
                            column,
                            config,
                            diagnostics,
                        );
                    }
                }
            }
        }
    }
}

/// Returns true if the name is lowerCamelCase (starts lowercase, no underscores).
fn is_lower_camel_case(name: &[u8]) -> bool {
    if name.is_empty() {
        return true;
    }
    if name[0].is_ascii_uppercase() {
        return false;
    }
    for &b in name {
        if b == b'_' {
            return false;
        }
        if !(b.is_ascii_alphanumeric()) {
            return false;
        }
    }
    true
}

#[cfg(test)]
mod tests {
    use super::*;
    crate::cop_fixture_tests!(VariableName, "cops/naming/variable_name");

    #[test]
    fn config_enforced_style_camel_case() {
        use crate::testutil::run_cop_full_with_config;
        use std::collections::HashMap;

        let config = CopConfig {
            options: HashMap::from([(
                "EnforcedStyle".into(),
                serde_yml::Value::String("camelCase".into()),
            )]),
            ..CopConfig::default()
        };
        let source = b"myVar = 1\n";
        let diags = run_cop_full_with_config(&VariableName, source, config);
        assert!(
            diags.is_empty(),
            "camelCase variable should not be flagged in camelCase mode"
        );
    }

    #[test]
    fn config_enforced_style_camel_case_flags_snake() {
        use crate::testutil::run_cop_full_with_config;
        use std::collections::HashMap;

        let config = CopConfig {
            options: HashMap::from([(
                "EnforcedStyle".into(),
                serde_yml::Value::String("camelCase".into()),
            )]),
            ..CopConfig::default()
        };
        let source = b"my_var = 1\n";
        let diags = run_cop_full_with_config(&VariableName, source, config);
        assert!(
            !diags.is_empty(),
            "snake_case variable should be flagged in camelCase mode"
        );
    }

    #[test]
    fn config_forbidden_identifiers() {
        use crate::testutil::run_cop_full_with_config;
        use std::collections::HashMap;

        let config = CopConfig {
            options: HashMap::from([(
                "ForbiddenIdentifiers".into(),
                serde_yml::Value::Sequence(vec![serde_yml::Value::String("data".into())]),
            )]),
            ..CopConfig::default()
        };
        let source = b"data = 1\n";
        let diags = run_cop_full_with_config(&VariableName, source, config);
        assert!(
            !diags.is_empty(),
            "Forbidden variable name should be flagged"
        );
        assert!(diags[0].message.contains("forbidden"));
    }

    #[test]
    fn config_forbidden_patterns() {
        use crate::testutil::run_cop_full_with_config;
        use std::collections::HashMap;

        let config = CopConfig {
            options: HashMap::from([(
                "ForbiddenPatterns".into(),
                serde_yml::Value::Sequence(vec![serde_yml::Value::String("_tmp\\z".into())]),
            )]),
            ..CopConfig::default()
        };
        let source = b"data_tmp = 1\n";
        let diags = run_cop_full_with_config(&VariableName, source, config);
        assert!(
            !diags.is_empty(),
            "Variable matching forbidden pattern should be flagged"
        );
    }
}
