foo.map(&:to_s)
bar.select(&:valid?)
items.reject(&:nil?)
foo.map { |x| x.to_s(16) }
bar.each { |x| puts x }
baz.map { |x, y| x + y }
# Safe navigation can't be converted to &:method
items.map { |x| x&.name }
args.filter_map { |a| a&.value }
# Hash literal receiver with select/reject is unsafe (rubocop#10864)
{foo: 42}.select { |item| item.bar }
{foo: 42}.reject { |item| item.bar }
# Array literal receiver with min/max is unsafe
[1, 2, 3].min { |item| item.foo }
[1, 2, 3].max { |item| item.foo }
# Destructuring block argument (trailing comma)
something { |x,| x.first }
# Block with no arguments
something { x.method }
# Empty block body
something { |x| }
# Block with more than 1 expression
something { |x| x.method; something_else }
# Method in body not called on block arg
something { |x| y.method }
# Block with splat params
something { |*x| x.first }
# Block argument
something { |&x| x.call }
# Ruby 3.4 it-block: safe navigation can't be converted
items.map { it&.name }
# Ruby 3.4 it-block: method has arguments
items.map { it.to_s(16) }
# Ruby 3.4 it-block: hash literal receiver
{foo: 42}.select { it.bar }
{foo: 42}.reject { it.bar }
# Ruby 3.4 it-block: array literal receiver with min/max
[1, 2, 3].min { it.foo }
[1, 2, 3].max { it.foo }
# Numbered param _1: safe navigation
items.map { _1&.name }
# Numbered param _1: method has arguments
items.map { _1.to_s(16) }
# Numbered param _1: hash literal receiver
{foo: 42}.select { _1.bar }
{foo: 42}.reject { _1.bar }
# Numbered param _1: array literal receiver with min/max
[1, 2, 3].min { _1.foo }
[1, 2, 3].max { _1.foo }
# Numbered param _2 (only _1 maps to single param)
something { _2.first }
