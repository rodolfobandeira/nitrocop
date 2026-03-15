unless x
  do_something
end

if !x
  do_something
else
  do_other
end

if x
  do_something
end

do_something unless x

if x && y
  do_something
end

# Double negation (!! is NOT a single negation)
if !!condition
  do_something
end

return if !!ENV["testing"]

something if !!value

# Negation as only part of a compound condition
if !condition && another_condition
  do_something
end

some_method if not condition or another_condition

# if/else with negated condition is accepted
if not a_condition
  some_method
elsif other_condition
  something_else
end
