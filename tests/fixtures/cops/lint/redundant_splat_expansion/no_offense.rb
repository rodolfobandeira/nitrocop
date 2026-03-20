c = [1, 2, 3]
a = *c
a, b = *c
a, *b = *c
a = *1..10
a = ['a']

# AllowPercentLiteralArrayArgument: true (default)
delegate(*%i[values_for_type custom?], to: :@nil)
do_something(*%w[foo bar baz])
remove_columns :table, *%i[col1 col2 col3], type: :boolean

# [] method calls with percent literal splat (AllowPercentLiteralArrayArgument)
NoteSet[*%w[C D E]]
Hash[*%w[hello world]]
obj[*%w[a b c]]
@cmd[*%w[test roar]]

# Array.new in multi-element array literal — not flagged
[1, 2, *Array.new(foo), 6]

# Array.new in when clause — not flagged
case foo
when *Array.new(3) { 42 }
  bar
end

# Array.new in rescue clause — not flagged
begin
  foo
rescue *Array.new(3) { 42 }
  bar
end
