Thread.list.select do |t|
  t.alive?
end.map do |t|
^^^^^^^ Style/MultilineBlockChain: Avoid multi-line chains of blocks.
  t.object_id
end

items.select { |i|
  i.valid?
}.map { |i|
^^^^^ Style/MultilineBlockChain: Avoid multi-line chains of blocks.
  i.name
}

foo.each do |x|
  x
end.map do |y|
^^^^^^^ Style/MultilineBlockChain: Avoid multi-line chains of blocks.
  y.to_s
end

# Intermediate method chain: end.c1.c2 do
a do
  b
end.c1.c2 do
^^^^^^^^^ Style/MultilineBlockChain: Avoid multi-line chains of blocks.
  d
end

# Safe navigation: end&.c do
a do
  b
end&.c do
^^^^^^ Style/MultilineBlockChain: Avoid multi-line chains of blocks.
  d
end

# Triple chain: two offenses
a do
  b
end.c do
^^^^^ Style/MultilineBlockChain: Avoid multi-line chains of blocks.
  d
end.e do
^^^^^ Style/MultilineBlockChain: Avoid multi-line chains of blocks.
  f
end

# Curly brace chain where first block is multiline
Thread.list.find_all { |t|
  t.alive?
}.map { |thread| thread.object_id }
^^^^^ Style/MultilineBlockChain: Avoid multi-line chains of blocks.
