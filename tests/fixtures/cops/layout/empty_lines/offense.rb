x = 1


^ Layout/EmptyLines: Extra blank line detected.
y = 2


^ Layout/EmptyLines: Extra blank line detected.

^ Layout/EmptyLines: Extra blank line detected.
z = 3

# Consecutive blank lines between code and trailing comments
a = 1


^ Layout/EmptyLines: Extra blank line detected.
# trailing comment

b = 2


^ Layout/EmptyLines: Extra blank line detected.
# another comment

# Consecutive blank lines inside =begin/=end block comments ARE offenses.
# RuboCop's tokens include embdoc tokens for =begin/=end content lines.
=begin
some documentation


^ Layout/EmptyLines: Extra blank line detected.
more documentation
=end
