@some_variable ||= begin
  if some_condition_is_met
    some_value
  else
    do_something
  end
end

x = if condition
  return 1
end

some_value += begin
  if rand(1..2).odd?
    "odd number"
  else
    "even number"
  end
end

some_value -= begin
  2
end
