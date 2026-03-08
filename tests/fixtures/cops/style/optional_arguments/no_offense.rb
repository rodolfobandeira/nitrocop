def foo(a, b = 1)
end
def bar(a, b, c)
end
def baz(a = 1)
end
def qux(a = 1, b = 2)
end
def quux
end
# Destructured params in post position are not required arguments
def destructure(a=1, (b,c)); [a,b,c]; end
def destructure_multi(a=1, f=2, (b,c), (d,e)); end
def destructure_with_rest(a=1, (b,*c)); [a,b,c]; end
# Class methods (def self.xxx) are not checked — RuboCop only fires on_def, not on_defs
def self.class_method(a = 1, b)
end
def self.multi_opt(a = 1, b = 2, c)
end
def self.with_mixed(a, b = 1, c)
end
