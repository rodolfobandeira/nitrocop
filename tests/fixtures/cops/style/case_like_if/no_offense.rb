case x
when 1
when 2
when 3
end

if x == 1
elsif x == 2
end

if x > 1
elsif x < 0
elsif x.nil?
end

# Different variables in each branch - not case-like
if x == 1
elsif y == 2
elsif z == 3
end

# Mixed comparison types with different targets
if x == 1
elsif y.is_a?(Integer)
elsif z === String
end

# Non-comparison conditions
if foo?
elsif bar?
elsif baz?
end

# Mixed-case constants are not literals (class references, not const references)
# RuboCop only treats ALL_UPPERCASE constants as literals
if cop == Foo::Bar
elsif cop == Baz::Qux
elsif cop == Something
else
  default_action
end

# match? with non-regexp should not be flagged (RuboCop requires regexp)
if x.match?(y)
elsif x.match?('str')
elsif x.match?(z)
end

# == with class reference on value side should not be flagged
if x == Foo
elsif Bar == x
elsif Baz == x
end

# One branch has == with class reference (mixed with literals)
if x == 1
elsif x == Foo
elsif x == 3
end

# == with method call arguments on both sides - not case-like
if x == foo(1)
elsif bar(1) == x
elsif baz(2) == x
end

# match? without a receiver
if match?(/foo/)
elsif x.match?(/bar/)
elsif x.match?(/baz/)
end
