a = cond ? b : c

foo ? bar : baz

x ? 1 : 2

result = x > 0 ? 'positive' : 'non-positive'

do_something(arg.foo ? bar : baz)

options.merge(
  current_page > 1 ? {
    previous_page: {
      href: page_path(current_page - 1),
    },
  } : {},
)

# Multiline condition but ternary branches on one line, inside a method call
do_something(arg
               .foo ? bar : baz)

# Multiline condition inside return
return arg
         .foo ? bar : baz

# Multiline condition inside another method call
process arg
          .value ? 'yes' : 'no'

# Multiline condition inside safe navigation method call
obj&.do_something arg
                    .foo ? bar : baz
