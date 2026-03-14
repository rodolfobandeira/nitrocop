x = [:a,
     :b]

y = [
  :a,
  :b
]

z = [:a, :b]

a = [
  :one,
  :two,
  :three
]

# Percent literal - symmetrical: open separate, close separate
b = %w(
  foo
  bar
  baz
)

# Percent literal - symmetrical: open same line, close same line
c = %w(one
  two
  three)

# Single-line percent literal
d = %w(foo bar baz)

# Heredoc in last element should be skipped
msgs = [<<~MSG,
  External link failed.
  Something went wrong.
MSG
]

# Heredoc in last element - array with heredoc
data = [false, <<-CONF
  k1 v1
  k2 "stringVal"
CONF
]
