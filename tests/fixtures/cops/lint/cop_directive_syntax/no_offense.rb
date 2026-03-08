# rubocop:disable Layout/LineLength
# rubocop:disable Layout
# rubocop:disable Layout/LineLength, Style/Encoding
# rubocop:disable all
# rubocop:enable Layout/LineLength
# rubocop:todo Layout/LineLength
# "rubocop:disable Layout/LineLength"
# # rubocop:disable Layout/LineLength
# rubocop:disable Layout/LineLength -- This is a good comment.
a = 1 # rubocop:disable Layout/LineLength -- This is a good comment.

# Space after colon is valid (rubocop allows optional whitespace around colon)
# rubocop: disable Layout/LineLength
# rubocop: enable Layout/LineLength
# rubocop: disable Layout/LineLength, Style/Encoding
# rubocop: todo Layout/LineLength
# rubocop: disable all
a = 1 # rubocop: disable Layout/LineLength -- comment here

# push/pop without cop names is valid
# rubocop:push
# rubocop:pop

# Directives inside heredocs should not be detected
code = <<~RUBY
  # rubocop:
  # rubocop:invalid
  # rubocop:disable
RUBY
puts code

# Directives mentioned in documentation comments should not be detected
# Checks that `# rubocop:enable` and `# rubocop:disable` are formatted correctly.
# Example: `# rubocop:disable Foo/Bar` is valid.
