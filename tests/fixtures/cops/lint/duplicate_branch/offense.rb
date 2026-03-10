# if/elsif duplicate
if condition
  do_something
elsif other
^^^^^^^^^^^^^ Lint/DuplicateBranch: Duplicate branch body detected.
  do_something
end

# if/else duplicate
if foo
  do_foo
else
^^^^ Lint/DuplicateBranch: Duplicate branch body detected.
  do_foo
end

# unless/else duplicate
unless foo
  do_bar
else
^^^^ Lint/DuplicateBranch: Duplicate branch body detected.
  do_bar
end

# ternary duplicate
res = foo ? do_foo : do_foo
                     ^^^^^^ Lint/DuplicateBranch: Duplicate branch body detected.

# case/when duplicate
case x
when 1
  :foo
when 2
^^^^^^ Lint/DuplicateBranch: Duplicate branch body detected.
  :foo
when 3
  :bar
end

# case/else duplicate
case x
when :a
  do_foo
else
^^^^ Lint/DuplicateBranch: Duplicate branch body detected.
  do_foo
end

# case with multiple duplicate whens
case x
when :a
  do_foo
when :b
  do_bar
when :c
^^^^^^^ Lint/DuplicateBranch: Duplicate branch body detected.
  do_foo
when :d
^^^^^^^ Lint/DuplicateBranch: Duplicate branch body detected.
  do_bar
end

# if with multiple duplicate branches
if foo
  do_foo
elsif bar
  do_bar
elsif baz
^^^^^^^^^ Lint/DuplicateBranch: Duplicate branch body detected.
  do_foo
elsif quux
^^^^^^^^^^ Lint/DuplicateBranch: Duplicate branch body detected.
  do_bar
end

# rescue with duplicate branches
begin
  do_something
rescue FooError
  handle_error(x)
rescue BarError
^^^^^^^^^^^^^^^ Lint/DuplicateBranch: Duplicate branch body detected.
  handle_error(x)
end

# rescue with else duplicate
begin
  do_something
rescue FooError
  handle_error(x)
else
^^^^ Lint/DuplicateBranch: Duplicate branch body detected.
  handle_error(x)
end

# rescue with multiple duplicates
begin
  do_something
rescue FooError
  handle_foo_error(x)
rescue BarError
  handle_bar_error(x)
rescue BazError
^^^^^^^^^^^^^^^ Lint/DuplicateBranch: Duplicate branch body detected.
  handle_foo_error(x)
rescue QuuxError
^^^^^^^^^^^^^^^^ Lint/DuplicateBranch: Duplicate branch body detected.
  handle_bar_error(x)
end

# case-in (pattern matching) duplicate
case foo
in x then do_foo
in y then do_foo
^^^^^^^^^^^^^^^^ Lint/DuplicateBranch: Duplicate branch body detected.
end
