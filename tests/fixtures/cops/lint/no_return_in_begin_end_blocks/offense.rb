@some_variable ||= begin
  return some_value if some_condition_is_met
  ^^^^^^ Lint/NoReturnInBeginEndBlocks: Do not `return` in `begin..end` blocks in assignment contexts.

  do_something
end

x = begin
  return 1
  ^^^^^^ Lint/NoReturnInBeginEndBlocks: Do not `return` in `begin..end` blocks in assignment contexts.
end

@var = begin
  return :foo
  ^^^^^^ Lint/NoReturnInBeginEndBlocks: Do not `return` in `begin..end` blocks in assignment contexts.
end

# Operator assignments (+=, -=, *=, /=, **=)
some_value = 10

some_value += begin
  return 1 if rand(1..2).odd?
  ^^^^^^ Lint/NoReturnInBeginEndBlocks: Do not `return` in `begin..end` blocks in assignment contexts.
  2
end

some_value -= begin
  return 1
  ^^^^^^ Lint/NoReturnInBeginEndBlocks: Do not `return` in `begin..end` blocks in assignment contexts.
end

some_value *= begin
  return 1
  ^^^^^^ Lint/NoReturnInBeginEndBlocks: Do not `return` in `begin..end` blocks in assignment contexts.
end

@@class_var += begin
  return 1
  ^^^^^^ Lint/NoReturnInBeginEndBlocks: Do not `return` in `begin..end` blocks in assignment contexts.
end

$global_var **= begin
  return 1
  ^^^^^^ Lint/NoReturnInBeginEndBlocks: Do not `return` in `begin..end` blocks in assignment contexts.
end

CONST = begin
  return 1
  ^^^^^^ Lint/NoReturnInBeginEndBlocks: Do not `return` in `begin..end` blocks in assignment contexts.
end
