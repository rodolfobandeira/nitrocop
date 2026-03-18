x = ()
    ^^ Lint/EmptyExpression: Avoid empty expressions.

foo(())
    ^^ Lint/EmptyExpression: Avoid empty expressions.

if ()
   ^^ Lint/EmptyExpression: Avoid empty expressions.
  bar
end

"result is #{}"
           ^^^ Lint/EmptyExpression: Avoid empty expressions.

`command #{}`
         ^^^ Lint/EmptyExpression: Avoid empty expressions.

puts "Defined attacks: #{}"
                       ^^^ Lint/EmptyExpression: Avoid empty expressions.
