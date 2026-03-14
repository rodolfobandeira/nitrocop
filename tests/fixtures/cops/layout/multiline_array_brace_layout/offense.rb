x = [:a,
  :b
]
^ Layout/MultilineArrayBraceLayout: The closing array brace must be on the same line as the last array element when the opening brace is on the same line as the first array element.

y = [
  :a,
  :b]
    ^ Layout/MultilineArrayBraceLayout: The closing array brace must be on the line after the last array element when the opening brace is on a separate line from the first array element.

z = [:c,
  :d
]
^ Layout/MultilineArrayBraceLayout: The closing array brace must be on the same line as the last array element when the opening brace is on the same line as the first array element.

# Percent literal arrays - closing on same line as last element (symmetrical: open on separate line)
options = %w(
  glossary.html
  faq.html
  sitemap.html
  search.html
  quickstart.html
  list_of_all_modules.html)
                          ^ Layout/MultilineArrayBraceLayout: The closing array brace must be on the line after the last array element when the opening brace is on a separate line from the first array element.

# Percent literal with %i
syms = %i(
  foo
  bar
  baz)
     ^ Layout/MultilineArrayBraceLayout: The closing array brace must be on the line after the last array element when the opening brace is on a separate line from the first array element.

# Percent literal - symmetrical: opening same line as first, closing on different line
names = %w(alpha
  beta
)
^ Layout/MultilineArrayBraceLayout: The closing array brace must be on the same line as the last array element when the opening brace is on the same line as the first array element.
