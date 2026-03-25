x = %w(foo bar baz)
y = %i(one two three)
z = %w[a b c]
a = [1, 2, 3]
b = %w()
c = %i(single)
d = %w(
  foo bar baz
  one two three
)
e = %i(
  alpha beta
)
# Tab-indented multiline %w should not flag leading whitespace as double spaces
f = %w[packsswb pcmpgtb pcmpgtw pcmpgtd packuswb packssdw
	   punpckhbw punpckhwd punpckhdq punpcklqdq punpckhqdq
].freeze
# Mixed tabs and spaces for indentation in multiline %w
g = %w(
	alpha beta gamma
	delta epsilon
)
