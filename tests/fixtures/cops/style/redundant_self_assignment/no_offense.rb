arr.sort!
str.gsub!('a', 'b')
arr = arr.sort
str = str.gsub('a', 'b')
x = y.sort!
result = items.map!(&:to_s)

# Bang methods that return nil when no change — NOT redundant
str = str.sub!('a', 'b')
str = str.gsub!('a', 'b')
str = str.chomp!("\n")
str = str.chop!
str = str.strip!
str = str.lstrip!
str = str.rstrip!
str = str.squeeze!(' ')
str = str.tr!('a', 'b')
str = str.tr_s!('a', 'b')
str = str.delete!('a')
str = str.downcase!
str = str.upcase!
str = str.swapcase!
str = str.capitalize!
str = str.encode!('UTF-8')
str = str.unicode_normalize!
str = str.scrub!

# Array/Hash methods that return nil when no change
arr = arr.compact!
arr = arr.flatten!
arr = arr.uniq!
arr = arr.reject! { |x| x > 1 }
arr = arr.select! { |x| x > 1 }
arr = arr.filter! { |x| x > 1 }
arr = arr.collect_concat! { |x| [x] }
arr = arr.slice!(0)

# self.foo = foo.concat(ary) — attribute assignment to self
self.foo = foo.concat(ary)

# Attribute assignment with block — RuboCop doesn't flag these
config.server_tag_roles = config.server_tag_roles.transform_values! { |v| v.split('/') }
other.items = other.items.delete_if { |x| x.nil? }
