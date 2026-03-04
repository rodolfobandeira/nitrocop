def foo(&block)
  if block_given?
     ^^^^^^^^^^^^^ Performance/BlockGivenWithExplicitBlock: Check `block` instead of using `block_given?` with explicit `&block` parameter.
    block.call
  end
end
def method(x, &block)
  do_something if block_given?
                  ^^^^^^^^^^^^^ Performance/BlockGivenWithExplicitBlock: Check `block` instead of using `block_given?` with explicit `&block` parameter.
end
def self.method(x, &block)
  do_something if block_given?
                  ^^^^^^^^^^^^^ Performance/BlockGivenWithExplicitBlock: Check `block` instead of using `block_given?` with explicit `&block` parameter.
end
def method(x, &myblock)
  do_something if block_given?
                  ^^^^^^^^^^^^^ Performance/BlockGivenWithExplicitBlock: Check `block` instead of using `block_given?` with explicit `&block` parameter.
end

# FN fix: block_given? inside negation (parsed as CallNode :! with receiver)
def negated_check(&block)
  raise "no block" unless block_given?
                          ^^^^^^^^^^^^^ Performance/BlockGivenWithExplicitBlock: Check `block` instead of using `block_given?` with explicit `&block` parameter.
end

def bang_negated(&block)
  return if !block_given?
             ^^^^^^^^^^^^^ Performance/BlockGivenWithExplicitBlock: Check `block` instead of using `block_given?` with explicit `&block` parameter.
  block.call
end

# FN fix: block_given? as method argument
def as_argument(&block)
  log(block_given?)
      ^^^^^^^^^^^^^ Performance/BlockGivenWithExplicitBlock: Check `block` instead of using `block_given?` with explicit `&block` parameter.
end

# FN fix: block_given? inside ternary
def in_ternary(&block)
  block_given? ? block.call : default
  ^^^^^^^^^^^^^ Performance/BlockGivenWithExplicitBlock: Check `block` instead of using `block_given?` with explicit `&block` parameter.
end

# FN fix: qualified ::Kernel.block_given?
def with_qualified_kernel(&block)
  if ::Kernel.block_given?
     ^^^^^^^^^^^^^^^^^^^^^^ Performance/BlockGivenWithExplicitBlock: Check `block` instead of using `block_given?` with explicit `&block` parameter.
    block.call
  end
end

def with_kernel_receiver(&block)
  do_something if Kernel.block_given?
                  ^^^^^^^^^^^^^^^^^^^^ Performance/BlockGivenWithExplicitBlock: Check `block` instead of using `block_given?` with explicit `&block` parameter.
end

# FN fix: block_given? as keyword argument value
def as_keyword_arg(&block)
  render(timing: block_given?)
                 ^^^^^^^^^^^^^ Performance/BlockGivenWithExplicitBlock: Check `block` instead of using `block_given?` with explicit `&block` parameter.
end

# FN fix: block_given? as default value for keyword parameter in method signature
def open(text, timing: block_given?, &block)
                       ^^^^^^^^^^^^^ Performance/BlockGivenWithExplicitBlock: Check `block` instead of using `block_given?` with explicit `&block` parameter.
  do_something
end

# FN fix: block_given? as default value for optional positional parameter
def process(flag = block_given?, &block)
                   ^^^^^^^^^^^^^ Performance/BlockGivenWithExplicitBlock: Check `block` instead of using `block_given?` with explicit `&block` parameter.
  do_something
end
