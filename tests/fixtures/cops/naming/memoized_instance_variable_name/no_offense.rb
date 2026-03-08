def foo
  @foo ||= compute
end
def bar?
  @bar ||= calculate
end
def something
  @something ||= fetch
end
def value
  @value ||= expensive
end

# Not memoization: ||= is not the sole/last statement in method body
def setting(key, options = {})
  @definitions ||= {}
  UserSettings::Setting.new(key, options)
end

def readpartial(size)
  @deadline ||= Process.clock_gettime(Process::CLOCK_MONOTONIC) + @read_deadline
  @socket.read_nonblock(size)
end

def process_url
  @card ||= PreviewCard.new(url: @url)
  attempt_oembed || attempt_opengraph
end

# defined? memoization pattern with matching name
def issue_token
  return @issue_token if defined?(@issue_token)
  @issue_token = create_token
end

# defined? with bang method (! stripped)
def compute!
  return @compute if defined?(@compute)
  @compute = heavy_calculation
end

# Setter method: = suffix stripped from method name
def max_time=(value)
  @max_time ||= value
end

def tab_color=(value)
  @tab_color ||= value
end

# Leading underscore method in disallowed style: @ivar matches method without leading _
def _rate_limit_key
  @rate_limit_key ||= compute_key
end

def _strategies
  @strategies ||= build_strategies
end

# define_method with matching ivar name
define_method(:values) do
  @values ||= do_something
end

# define_singleton_method with matching ivar name
define_singleton_method(:records) do
  @records ||= fetch_records
end

# klass.define_method with matching ivar name
klass.define_method(:items) do
  @items ||= load_items
end

# singleton method (def self.x) with matching ivar
def self.records
  @records ||= fetch_records
end
