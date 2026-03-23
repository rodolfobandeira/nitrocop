# Consecutive each loops
items.each { |item| do_something(item) }
items.each { |item| do_something_else(item, arg) }
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Style/CombinableLoops: Combine this loop with the previous loop.

# Three consecutive loops
items.each { |item| foo(item) }
items.each { |item| bar(item) }
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Style/CombinableLoops: Combine this loop with the previous loop.
items.each { |item| baz(item) }
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Style/CombinableLoops: Combine this loop with the previous loop.

# each_with_index
items.each_with_index { |item| do_something(item) }
items.each_with_index { |item| do_something_else(item, arg) }
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Style/CombinableLoops: Combine this loop with the previous loop.

# reverse_each
items.reverse_each { |item| do_something(item) }
items.reverse_each { |item| do_something_else(item, arg) }
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Style/CombinableLoops: Combine this loop with the previous loop.

# Blank lines between consecutive loops (no intervening code) — still an offense
items.each { |item| alpha(item) }

items.each { |item| beta(item) }
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Style/CombinableLoops: Combine this loop with the previous loop.

# for loops
for item in items do do_something(item) end
for item in items do do_something_else(item, arg) end
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Style/CombinableLoops: Combine this loop with the previous loop.

# each_with_object
items.each_with_object([]) { |item, acc| acc << item }
items.each_with_object([]) { |item, acc| acc << item.to_s }
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Style/CombinableLoops: Combine this loop with the previous loop.

# do...end blocks
items.each do |item| do_something(item) end
items.each { |item| do_something_else(item, arg) }
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Style/CombinableLoops: Combine this loop with the previous loop.

# Different block variable names — still an offense
items.each { |item| foo(item) }
items.each { |x| bar(x) }
^^^^^^^^^^^^^^^^^^^^^^^^^ Style/CombinableLoops: Combine this loop with the previous loop.

# each_key
hash.each_key { |k| do_something(k) }
hash.each_key { |k| do_something_else(k) }
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Style/CombinableLoops: Combine this loop with the previous loop.

# each_value
hash.each_value { |v| do_something(v) }
hash.each_value { |v| do_something_else(v) }
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Style/CombinableLoops: Combine this loop with the previous loop.

# each_pair
hash.each_pair { |k, v| do_something(k) }
hash.each_pair { |k, v| do_something_else(v) }
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Style/CombinableLoops: Combine this loop with the previous loop.

# Numbered block parameters
items.each { do_something(_1) }
items.each { do_something_else(_1, arg) }
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Style/CombinableLoops: Combine this loop with the previous loop.
