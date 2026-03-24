"Hello #{name}"
"#{user.name} <#{user.email}>"
format('%s <%s>', user.name, user.email)
array.join(', ')
"foobar"
x = 'hello'

# Interpolated string on RHS with non-literal LHS — not flagged because
# neither side is a plain string literal (str_type? in RuboCop)
ENV.fetch('KEY') + "/#{path}"
account.username + "_#{i}"
pretty + "\n#{" " * nesting}}"
request.path + "?sort=#{field}&order=#{order}"

# Interpolated string on LHS with non-literal RHS
"#{index} " + user.email
rule_message + "\n#{explanation}"

# Heredoc concatenation — not flagged (can't convert to interpolation)
code = <<EOM + code
hostname = Socket.gethostname
EOM

conf = @basic_conf + <<CONF
<match fluent.**>
  @type stdout
</match>
CONF

result = header + <<~HEREDOC
  some content here
HEREDOC

# Line-end concatenation (both sides str, + at end of line) — handled by Style/LineEndConcatenation
name = 'First' +
  'Last'

# Percent literal concatenation — in Prism these are StringNode but in Parser they're dstr
config + %[some value]
header + %{some value}

# Multi-line string literal — in Parser these are dstr (not str_type?)
# so RuboCop does not flag them. In Prism they are StringNode.
html = '
    <html>
        <head>
            <base href="' + base_url + '" />
        </head>
    </html>'

x = 'line1
line2' + y + 'line3
line4'

# Single-line string with escape sequence \n IS flagged (str_type? in Parser)
# but multi-line source is NOT. This tests the boundary.
# "hello\nworld" + name — would be flagged (single source line)
