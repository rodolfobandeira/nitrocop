"result is #{42}"
             ^^ Lint/LiteralInInterpolation: Literal interpolation detected.

"hello #{:world}"
         ^^^^^^ Lint/LiteralInInterpolation: Literal interpolation detected.

"value #{nil}"
         ^^^ Lint/LiteralInInterpolation: Literal interpolation detected.

"bool #{true}"
        ^^^^ Lint/LiteralInInterpolation: Literal interpolation detected.

"bool #{false}"
        ^^^^^ Lint/LiteralInInterpolation: Literal interpolation detected.

"float #{1.5}"
         ^^^ Lint/LiteralInInterpolation: Literal interpolation detected.

"range #{1..2}"
         ^^^^ Lint/LiteralInInterpolation: Literal interpolation detected.

"range #{1...2}"
         ^^^^^ Lint/LiteralInInterpolation: Literal interpolation detected.

"string #{"hello"}"
          ^^^^^^^ Lint/LiteralInInterpolation: Literal interpolation detected.

"string #{'hello'}"
          ^^^^^^^ Lint/LiteralInInterpolation: Literal interpolation detected.

"whitespace in non-heredoc #{' '}"
                             ^^^ Lint/LiteralInInterpolation: Literal interpolation detected.
