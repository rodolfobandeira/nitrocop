def foo
  bar
end

def baz = 42

def qux(x)
  x + 1
end

# Multiline endless methods without blank lines
def greet(name,
  greeting) = "#{greeting}, #{name}"

def compute(value,
  factor) =
  value * factor
