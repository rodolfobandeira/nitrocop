x = 1

y = 2

z = 3

# Consecutive blank lines between code and trailing comments
a = 1

# trailing comment

b = 2

# another comment

# Consecutive blank lines inside =begin/=end block comments ARE offenses.
# RuboCop's tokens include embdoc tokens for =begin/=end content lines.
=begin
some documentation

more documentation
=end
