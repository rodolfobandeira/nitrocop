"result is #{x == "foo"}"
                  ^^^^^ Style/StringLiteralsInInterpolation: Prefer single-quoted strings inside interpolations.

"hello #{hash["key"]}"
              ^^^^^ Style/StringLiteralsInInterpolation: Prefer single-quoted strings inside interpolations.

"test #{y.gsub("a", "b")}"
               ^^^ Style/StringLiteralsInInterpolation: Prefer single-quoted strings inside interpolations.
                    ^^^ Style/StringLiteralsInInterpolation: Prefer single-quoted strings inside interpolations.

"escape #{visit "\\"}"
                ^^^^ Style/StringLiteralsInInterpolation: Prefer single-quoted strings inside interpolations.

"split #{value.split("\\").last}"
                     ^^^^ Style/StringLiteralsInInterpolation: Prefer single-quoted strings inside interpolations.
