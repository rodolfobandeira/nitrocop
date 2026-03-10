# if/elsif with different branches
if condition
  do_something
elsif other
  do_other
end

# case/when with different branches
case x
when 1
  :foo
when 2
  :bar
when 3
  :baz
end

# Heredocs with different content in case/when branches (not duplicates)
case style
when :a
  <<~RUBY
    hello world
  RUBY
when :b
  <<~RUBY
    goodbye world
  RUBY
end

# Heredocs with different content in if/else branches (not duplicates)
if condition
  expect_offense(<<~RUBY)
    x = 1
    ^^^ Error one.
  RUBY
else
  expect_offense(<<~RUBY)
    x = 1
    ^^^ Error two.
  RUBY
end

# Simple if without other branches
if foo
  do_foo
end

# Simple unless without other branches
unless foo
  do_bar
end

# unless with different else branch
unless foo
  do_bar
else
  do_foo
end

# Ternary with different branches
res = foo ? do_foo : do_bar

# case with no duplicates
case x
when :a
  do_foo
when :b
  do_bar
end

# rescue with no duplicates
begin
  do_something
rescue FooError
  handle_foo_error(x)
rescue BarError
  handle_bar_error(x)
end

# Empty branches should not count as duplicates
if foo
  # Comment.
end

# Modifier if is not checked
do_foo if foo

# Modifier unless is not checked
do_bar unless foo
