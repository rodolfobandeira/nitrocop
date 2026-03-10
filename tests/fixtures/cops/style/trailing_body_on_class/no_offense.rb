class Foo
  def foo; end
end

class Bar
  bar = 1
end

class Baz < Base
  include Mod
end

class Empty; end

# Single-line class definitions are not offenses
class Foo; def foo; end; end
class Bar; bar = 1; end
class << self; self; end
class << obj; attr_accessor :name; end

# Class with rescue — body is on a separate line, not trailing
class ErrorHandler
  raise "message"
rescue => e
  puts e.message
end

# Singleton class with rescue — body is on a separate line
class << Object.new
  raise "message"
rescue => e
  puts e.message
end

# Class with ensure — body is on a separate line
class WithEnsure
  do_work
ensure
  cleanup
end
