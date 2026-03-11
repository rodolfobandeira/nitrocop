a = cond ?
    ^^^^^^ Style/MultilineTernaryOperator: Avoid multi-line ternary operators, use `if` or `unless` instead.
  b : c

cond ? b :
^^^^ Style/MultilineTernaryOperator: Avoid multi-line ternary operators, use `if` or `unless` instead.
c

a = cond ?
    ^^^^^^ Style/MultilineTernaryOperator: Avoid multi-line ternary operators, use `if` or `unless` instead.
    b :
    c

return cond ?
       ^^^^^^ Style/MultilineTernaryOperator: Avoid multi-line ternary operators, use single-line instead.
       foo :
       bar

do_something cond ?
             ^^^^^^ Style/MultilineTernaryOperator: Avoid multi-line ternary operators, use single-line instead.
             foo :
             bar
