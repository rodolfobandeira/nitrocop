def good_method
  x = 1
end

def initialize
  @x = 1
end

def <=>(other)
  x <=> other
end

def <<(item)
  items << item
end

def []=(key, value)
  @hash[key] = value
end

def _private_method
  nil
end

def save!
  true
end

def valid?
  true
end

# Unicode characters in method names (not ASCII uppercase)
def elapsed_μs
  42
end

def nowµs
  Time.now
end

# CamelCase singleton factory methods (def self.X)
module Foo
  def self.Dimension(*args)
    new(*args)
  end

  def self.Point(*args)
    new(*args)
  end
end
