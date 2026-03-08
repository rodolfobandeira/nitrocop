items.each_with_object([]) { |item, acc| acc << item }
items.each { |item| puts item }
items.each_with_object({}) do |item, hash|
  hash[item] = true
end
items.inject({}) { |acc, item| acc.merge(item => true) }
# each_with_object called WITHOUT an argument — not redundant (missing object)
items.each_with_object { |v| v }
items.each_with_object { |v, o| v; o }
items.each_with_object do |v|
  v
end
items.each_with_object([]) { puts "hello" }
# zero-argument blocks change `each_with_object` semantics and are not redundant
items.each_with_object({}) { 42 }
[1, 2, 3].each_with_object(23) { break 42 }
