str.html_safe
    ^^^^^^^^^ Rails/OutputSafety: Tagging a string as html safe may be a security risk.
raw(content)
^^^ Rails/OutputSafety: Tagging a string as html safe may be a security risk.
variable.to_s.html_safe
              ^^^^^^^^^ Rails/OutputSafety: Tagging a string as html safe may be a security risk.
out.safe_concat(user_content)
    ^^^^^^^^^^^ Rails/OutputSafety: Tagging a string as html safe may be a security risk.
safe_join([i18n_text.safe_concat(i18n_text)])
                     ^^^^^^^^^^^ Rails/OutputSafety: Tagging a string as html safe may be a security risk.
# Formtastic::I18n is NOT the standard I18n — should still flag
raw(Formtastic::I18n.t('key'))
^^^ Rails/OutputSafety: Tagging a string as html safe may be a security risk.
