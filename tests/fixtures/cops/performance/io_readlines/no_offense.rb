IO.foreach('file') { |l| puts l }
File.foreach('file') { |l| puts l }
IO.readlines('file')
IO.readlines('file').size
File.readlines('testfile').not_enumerable_method
file.readlines.not_enumerable_method
::IO.foreach('file') { |l| puts l }

# Class-form (IO/File) with chained method that HAS arguments — no offense
# RuboCop's readlines_on_class? pattern only matches when outer call has no args
File.readlines(config).grep(/require /)
IO.readlines(file).first(2)
File.readlines(file, encoding: Encoding::BINARY).inject([]) { |list, line| list }
File.readlines(@filename).first(2).join
