while node
^^^^^ Lint/UnreachableLoop: This loop will have at most one iteration.
  do_something(node)
  node = node.parent
  break
end

items.each do |item|
^^^^^^^^^^ Lint/UnreachableLoop: This loop will have at most one iteration.
  return item if something?(item)
  raise NotFoundError
end

loop do
^^^^ Lint/UnreachableLoop: This loop will have at most one iteration.
  do_something
  break
end

# next in inner loop does NOT prevent outer loop from being flagged
until x > 0
^^^^^^^^^^^ Lint/UnreachableLoop: This loop will have at most one iteration.
  items.each do |item|
    next if item.odd?
    break
  end
  if x > 0
    break
  else
    raise MyError
  end
end

# case-when-else with all branches breaking
while x > 0
^^^^^^^^^^^ Lint/UnreachableLoop: This loop will have at most one iteration.
  case x
  when 1
    break
  else
    raise MyError
  end
end

# if-else with all branches breaking
while x > 0
^^^^^^^^^^^ Lint/UnreachableLoop: This loop will have at most one iteration.
  if condition
    break
  else
    raise MyError
  end
end

# each_key, each_pair, each_value are also loop methods
data.each_key { fail }
^^^^^^^^^^^^^^ Lint/UnreachableLoop: This loop will have at most one iteration.

data.each_pair { fail }
^^^^^^^^^^^^^^^ Lint/UnreachableLoop: This loop will have at most one iteration.

data.each_value { fail }
^^^^^^^^^^^^^^^^ Lint/UnreachableLoop: This loop will have at most one iteration.

# grep block with unconditional return
files.grep(pattern) { |l| return true }
^^^^^^^^^^^^^^^^^^^ Lint/UnreachableLoop: This loop will have at most one iteration.

# cycle with unconditional raise
items.cycle { raise StopIteration }
^^^^^^^^^^^ Lint/UnreachableLoop: This loop will have at most one iteration.

# reject! with unconditional raise
items.reject! { raise StandardError }
^^^^^^^^^^^^^ Lint/UnreachableLoop: This loop will have at most one iteration.

# select! with unconditional raise
items.select! { raise StandardError }
^^^^^^^^^^^^^ Lint/UnreachableLoop: This loop will have at most one iteration.

# filter with unconditional return
items.filter { |x| return x }
^^^^^^^^^^^^ Lint/UnreachableLoop: This loop will have at most one iteration.

# sort_by with unconditional return
items.sort_by { |x| return x }
^^^^^^^^^^^^^ Lint/UnreachableLoop: This loop will have at most one iteration.

# find_all with unconditional return
items.find_all { |x| return x }
^^^^^^^^^^^^^^ Lint/UnreachableLoop: This loop will have at most one iteration.

# each_entry with unconditional raise
data.each_entry { raise StandardError }
^^^^^^^^^^^^^^^^ Lint/UnreachableLoop: This loop will have at most one iteration.

# return ... || break — the `break` does NOT provide continuation
[nil, nil, 42].each do |value|
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Lint/UnreachableLoop: This loop will have at most one iteration.
  return do_something(value) || break
end

# chained method call: the last method in chain is the loop
string.split('-').map { raise StandardError }
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Lint/UnreachableLoop: This loop will have at most one iteration.
