variable.to_sym
:foo.to_s
x.to_sym
name = 'foo'
name.to_sym
result = :bar
{ normal: 'val' }
{ another_key: 1, foo: 2 }
{ 'has-hyphen': 1 }
{ 'has space': 1 }
{ "7_days": 1 }
:'foo-bar'
:"foo-bar"
:'Foo/Bar/Baz'
:'foo-bar""'
:normal
{ '==': 'bar' }
{ 'foo:bar': 'bar' }
{ 'foo=': 'bar' }
to_sym == other
%i(foo bar)
alias foo bar
{ foo: :bar }
