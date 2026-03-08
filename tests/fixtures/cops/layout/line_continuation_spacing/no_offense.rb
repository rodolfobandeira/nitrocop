one_plus_one = 1 \
  + 1

two_plus_two = 2 \
  + 2

three = 3 \
  + 0

# Backslash inside heredoc should not be flagged
x = <<~SQL
  SELECT * FROM users \
  WHERE id = 1
SQL

y = <<~SHELL
  echo hello \
  world
SHELL

z = <<~RUBY
  foo(bar, \
      baz)
RUBY

# Backslash immediately after closing string delimiter (implicit concatenation)
raise TypeError, "Argument must be a Binding, not "\
    "a #{scope.class.name}"

msg = "Expected result "\
    "but found something else"

debugMsg(2, "Starting at position %d: prefix = %s, "\
         "delimiter = %s, quoted = %s",
         pos, prefix, delim, quoted)

raise MatchFailure, "Mismatched bracket at offset %d: "\
    "Expected '%s', but found '%s' instead." %
    [offset, expected, actual]

# Single-quoted string followed by backslash continuation
result = 'hello '\
    'world'

# Backslash after closing quote with no space (no_space style would be fine too)
x = 'first'\
    'second'
