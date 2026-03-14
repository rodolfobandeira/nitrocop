x = %w(foo  bar  baz)
          ^^ Layout/SpaceInsideArrayPercentLiteral: Use only a single space inside array percent literal.
               ^^ Layout/SpaceInsideArrayPercentLiteral: Use only a single space inside array percent literal.
y = %i(one  two  three)
          ^^ Layout/SpaceInsideArrayPercentLiteral: Use only a single space inside array percent literal.
               ^^ Layout/SpaceInsideArrayPercentLiteral: Use only a single space inside array percent literal.
z = %w[a  b  c]
        ^^ Layout/SpaceInsideArrayPercentLiteral: Use only a single space inside array percent literal.
           ^^ Layout/SpaceInsideArrayPercentLiteral: Use only a single space inside array percent literal.
m = %w(
  foo  bar  baz
     ^^ Layout/SpaceInsideArrayPercentLiteral: Use only a single space inside array percent literal.
          ^^ Layout/SpaceInsideArrayPercentLiteral: Use only a single space inside array percent literal.
  one  two
     ^^ Layout/SpaceInsideArrayPercentLiteral: Use only a single space inside array percent literal.
)
n = %i(
  alpha  beta
       ^^ Layout/SpaceInsideArrayPercentLiteral: Use only a single space inside array percent literal.
)
p = %W(
  dec  deref  dissoc
     ^^ Layout/SpaceInsideArrayPercentLiteral: Use only a single space inside array percent literal.
            ^^ Layout/SpaceInsideArrayPercentLiteral: Use only a single space inside array percent literal.
)
