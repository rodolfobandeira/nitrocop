%w[foo bar]
%i[foo bar]
%W[cat dog]
%I[hello world]
%r{pattern}
%q(string)
# percent-like text inside a string should not trigger
x = "use %w(foo bar) for arrays"
y = 'try %r{pattern} for regexp'
# percent-like text inside a comment: %i(sym1 sym2)
# %w with non-preferred delimiters where content contains the delimiter chars
z = %w(foo( bar))
a = %i(open[ close])
