class Foo
  def bar
    super
    do_something_else
  end

  def baz(x)
    x + 1
  end

  def qux
    42
  end

  # Methods with default arguments are not useless (change calling convention)
  def initialize(x = Object.new)
    super
  end

  # Methods with rest args are not useless
  def method_with_rest(*args)
    super
  end

  # Methods with optional keyword args are not useless
  def method_with_kwopt(name: 'default')
    super
  end

  # super with different args than def params is not useless
  def method_with_extra(a, b)
    super(:extra, a, b)
  end

  # super with reordered args is not useless
  def method_reordered(a, b)
    super(b, a)
  end

  # super with fewer args is not useless
  def method_fewer_args(a, b)
    super(a)
  end

  # super with a block adds behavior, not useless
  def create!
    super do |obj|
      obj.save!
    end
  end

  # super with a block (curly braces)
  def process
    super { |x| x.validate }
  end

  # Methods with keyword rest args are not useless
  def initialize(app, **)
    super app
  end

  # Generic method macro wrapping a def — not flagged
  memoize def computed_value
    super
  end

  # Another generic macro
  do_something def method
    super
  end

  # super with different keyword args
  def method_kw(a:)
    super(a: 42)
  end

  # Non-constructor with only comments — not useless
  def non_constructor
    # Comment.
  end

  # Empty constructor — not flagged by this cop
  def initialize(arg1, arg2)
  end

  # Class-level initialize is not flagged when empty
  def self.initialize
  end
end
