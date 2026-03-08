items.include?(x)
items.exclude?(x)
!items.empty?
items.any? { |i| i > 0 }
items.none? { |i| i.nil? }

# safe navigation — not flagged
!arr&.include?(x)

# multi-arg — not flagged
!arr.include?(x, y)

# no receiver — not flagged
!include?(x)
