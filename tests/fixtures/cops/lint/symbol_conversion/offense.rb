# Unnecessary to_sym on symbol literal
:foo.to_sym
^^^^^^^^^^^ Lint/SymbolConversion: Unnecessary symbol conversion; use `:foo` instead.

# Unnecessary to_sym on string literal
"foo".to_sym
^^^^^^^^^^^^ Lint/SymbolConversion: Unnecessary symbol conversion; use `:foo` instead.

# Unnecessary to_sym on string with underscores
"foo_bar".to_sym
^^^^^^^^^^^^^^^^ Lint/SymbolConversion: Unnecessary symbol conversion; use `:foo_bar` instead.

# Unnecessary to_sym on string requiring quoting
"foo-bar".to_sym
^^^^^^^^^^^^^^^^ Lint/SymbolConversion: Unnecessary symbol conversion; use `:"foo-bar"` instead.

# Unnecessary intern on symbol literal
:foo.intern
^^^^^^^^^^^ Lint/SymbolConversion: Unnecessary symbol conversion; use `:foo` instead.

# Unnecessary intern on string literal
"foo".intern
^^^^^^^^^^^^ Lint/SymbolConversion: Unnecessary symbol conversion; use `:foo` instead.

# Unnecessary intern on string with underscores
"foo_bar".intern
^^^^^^^^^^^^^^^^ Lint/SymbolConversion: Unnecessary symbol conversion; use `:foo_bar` instead.

# Unnecessary intern on string requiring quoting
"foo-bar".intern
^^^^^^^^^^^^^^^^ Lint/SymbolConversion: Unnecessary symbol conversion; use `:"foo-bar"` instead.

# Unnecessarily quoted standalone symbol (double quotes)
:"foo"
^^^^^^ Lint/SymbolConversion: Unnecessary symbol conversion; use `:foo` instead.

# Unnecessarily quoted standalone symbol (double quotes, underscore)
:"foo_bar"
^^^^^^^^^^ Lint/SymbolConversion: Unnecessary symbol conversion; use `:foo_bar` instead.

# Unnecessarily quoted standalone symbol (single quotes)
:'foo'
^^^^^^ Lint/SymbolConversion: Unnecessary symbol conversion; use `:foo` instead.

# Unnecessarily quoted standalone symbol (single quotes, underscore)
:'foo_bar'
^^^^^^^^^^ Lint/SymbolConversion: Unnecessary symbol conversion; use `:foo_bar` instead.

# Unnecessarily quoted operator symbol
obj.send(:"+")
         ^^^^ Lint/SymbolConversion: Unnecessary symbol conversion; use `:+` instead.

# Unnecessarily quoted instance variable symbol
instance_variable_get :"@ivar"
                      ^^^^^^^^ Lint/SymbolConversion: Unnecessary symbol conversion; use `:@ivar` instead.

# Quoted hash key (string style)
{ 'name': 'val' }
  ^^^^^^^ Lint/SymbolConversion: Unnecessary symbol conversion; use `name:` instead.

# Quoted hash key (double-quoted string style)
{ "role": 'val' }
  ^^^^^^ Lint/SymbolConversion: Unnecessary symbol conversion; use `role:` instead.

# Multiple quoted hash keys
{ 'status': 1, "color": 2 }
  ^^^^^^^^^ Lint/SymbolConversion: Unnecessary symbol conversion; use `status:` instead.
               ^^^^^^^^ Lint/SymbolConversion: Unnecessary symbol conversion; use `color:` instead.

# Quoted symbol as hash value
{ foo: :'bar' }
       ^^^^^^ Lint/SymbolConversion: Unnecessary symbol conversion; use `:bar` instead.

# Quoted symbol as hash key (rocket style)
{ :'foo' => :bar }
  ^^^^^^ Lint/SymbolConversion: Unnecessary symbol conversion; use `:foo` instead.

# Quoted hash key ending with !
{ 'foo!': 'bar' }
  ^^^^^^^ Lint/SymbolConversion: Unnecessary symbol conversion; use `foo!:` instead.

# Quoted hash key ending with ?
{ 'foo?': 'bar' }
  ^^^^^^^ Lint/SymbolConversion: Unnecessary symbol conversion; use `foo?:` instead.
