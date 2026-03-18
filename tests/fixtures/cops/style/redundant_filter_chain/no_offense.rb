arr.any? { |x| x > 1 }
arr.none? { |x| x > 1 }
arr.select { |x| x > 1 }.count
arr.select(:name).any?
foo.select.any?
arr.select { |x| x > 1 }.any?(Integer)

# Blocks using `it` keyword (Ruby 3.4+) — RuboCop uses itblock AST node, not block
servers.filter { it.strand.label != "wait" }.any?
arr.select { it > 1 }.none?
arr.find_all { it.active? }.empty?

# Blocks using numbered parameters (_1) — RuboCop uses numblock AST node, not block
arr.select { _1 > 1 }.any?
arr.filter { _1.active? }.none?

# present?/many? require ActiveSupportExtensionsEnabled (not enabled by default)
arr.select { |x| x > 1 }.present?
arr.select { |x| x > 1 }.many?
