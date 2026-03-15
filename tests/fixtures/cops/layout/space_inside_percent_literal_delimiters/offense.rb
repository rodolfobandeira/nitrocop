x = %i( foo bar baz )
       ^ Layout/SpaceInsidePercentLiteralDelimiters: Do not use spaces inside percent literal delimiters.
                   ^ Layout/SpaceInsidePercentLiteralDelimiters: Do not use spaces inside percent literal delimiters.
y = %w( one two three )
       ^ Layout/SpaceInsidePercentLiteralDelimiters: Do not use spaces inside percent literal delimiters.
                     ^ Layout/SpaceInsidePercentLiteralDelimiters: Do not use spaces inside percent literal delimiters.
z = %w[ a b c ]
       ^ Layout/SpaceInsidePercentLiteralDelimiters: Do not use spaces inside percent literal delimiters.
             ^ Layout/SpaceInsidePercentLiteralDelimiters: Do not use spaces inside percent literal delimiters.
a = %x( ls -l )
       ^ Layout/SpaceInsidePercentLiteralDelimiters: Do not use spaces inside percent literal delimiters.
             ^ Layout/SpaceInsidePercentLiteralDelimiters: Do not use spaces inside percent literal delimiters.
b = %x[ echo hello ]
       ^ Layout/SpaceInsidePercentLiteralDelimiters: Do not use spaces inside percent literal delimiters.
                  ^ Layout/SpaceInsidePercentLiteralDelimiters: Do not use spaces inside percent literal delimiters.
c = %x( pwd )
       ^ Layout/SpaceInsidePercentLiteralDelimiters: Do not use spaces inside percent literal delimiters.
           ^ Layout/SpaceInsidePercentLiteralDelimiters: Do not use spaces inside percent literal delimiters.
d = %x( #{cmd} --flag )
       ^ Layout/SpaceInsidePercentLiteralDelimiters: Do not use spaces inside percent literal delimiters.
                     ^ Layout/SpaceInsidePercentLiteralDelimiters: Do not use spaces inside percent literal delimiters.
e = %w[
]
# nitrocop-expect: 8:7 Layout/SpaceInsidePercentLiteralDelimiters: Do not use spaces inside percent literal delimiters.
f = %w(
)
# nitrocop-expect: 10:7 Layout/SpaceInsidePercentLiteralDelimiters: Do not use spaces inside percent literal delimiters.
g = %i(
)
# nitrocop-expect: 12:7 Layout/SpaceInsidePercentLiteralDelimiters: Do not use spaces inside percent literal delimiters.
