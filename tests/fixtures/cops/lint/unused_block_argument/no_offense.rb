do_something do |used, _unused|
  puts used
end

do_something do
  puts :foo
end

[1, 2, 3].each do |x|
  puts x
end

do_something { |unused| }

items.map do |item|
  item.name
end

->(arg) { }

test do |key, value|
  puts something(binding)
end

1.times do |index; x|
  x = 10
  puts index
end

hash.each do |key, value|
  key, value = value, key
end

-> (_foo, bar) { puts bar }

# Nested block shadows outer param, but outer is also used directly
items.each do |item|
  puts item
  results.map do |item|
    item.name
  end
end

# Outer param used before nested block that shadows it
data.each do |value|
  puts value
  items.map do |value|
    value.to_s
  end
end

# Nested block does NOT shadow - different param name, both used
items.each do |item|
  results.map do |result|
    [item, result]
  end
end
