IO.foreach('file') { |l| puts l }
File.foreach('file') { |l| puts l }
IO.readlines('file')
IO.readlines('file').size
File.readlines('testfile').not_enumerable_method
file.readlines.not_enumerable_method
::IO.foreach('file') { |l| puts l }

# ConstantPathNode — class pattern should NOT match qualified constants
::File.readlines(path).map(&:chomp)
::TargetIO::File.readlines("/etc/fstab").reverse_each { |line| puts line }
::IO.readlines(path).each { |l| puts l }

# Class pattern with block_pass arg — should NOT match
File.readlines(path).map(&:chomp)
IO.readlines(path).reject(&:empty?)
