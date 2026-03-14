[1, 2, 3].empty?
!string.empty?
array.length == 1
array.length > 1
array.size
hash.size == 5

# Safe navigation chain - can't replace with empty?
foo if values&.length&.> 0

# File.stat().size is not a collection size
raise "empty" if File.stat(path).size.zero?
