File.exist?("foo")
Dir.exist?("bar")
MyClass.exists?("baz")
Custom::File.exists?("path")
File.new("qux")
Dir.entries("quux")
::File.exist?("corge")
ENV.values
ENV.to_h
ENV.clone(freeze: 1)
block_given?
attr :name
attr :name, attribute
attr_accessor :name
attr_reader :name
Foo.iterator?
Foo.gethostbyname
Foo.gethostbyaddr
