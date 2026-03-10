module Foo
  extend self
end

module Bar
  include Baz
end

module Qux
  def foo; end
end

module Empty; end

module ::TopLevel; def foo; '1'; end; end
module ::Other; def bar; '2'; end; end

# Module with rescue — body is on a separate line, not trailing
module ErrorHandler
  raise "message"
rescue => e
  puts e.message
end

# Module with ensure — body is on a separate line
module WithEnsure
  do_work
ensure
  cleanup
end
