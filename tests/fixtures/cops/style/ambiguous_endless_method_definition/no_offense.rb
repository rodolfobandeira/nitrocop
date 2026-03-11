def foo = (true and bar)
def foo = (true or bar)
def foo = true && bar
def foo = true || bar
(def foo = true) if bar

def initialize(message = 'root key must be a Symbol or a String')
  super
end

def logger.debug(msg); @seen = true if msg.include?('No custom attributes found'); end
def arg.to_s = "A" unless defined? arg.to_s

def foo
end
x = 1
