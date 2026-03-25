def foo
  42
end

def bar = 42

def baz(x)
  x + 1
end

# Single-line defs should not be flagged
def qux; 42; end
def quux(x); x + 1; end

# Modifier before def: end aligns with line start, not def keyword
private_class_method def self.helper(x)
  x + 1
end

# Tab-indented defs should not be flagged when end aligns with def
	def tab_method
		42
	end

	private def tab_modifier_method
		43
	end

# Non-modifier mid-line def: end aligns with def keyword (semicolons before def)
class H < Hash; def lookup(m)
                  m.to_s
                end; end

# Non-modifier mid-line def: end aligns with def keyword (boolean guard)
false && def guarded_method
           42
         end

# Line continuation before def: end aligns with statement start (helper_method)
  helper_method \
    def ordergroups_for_adding
    Ordergroup.undeleted.order(:name)
  end

# Nested line continuation before def with indentation
class Foo
  helper_method \
    def bar
    42
  end
end
