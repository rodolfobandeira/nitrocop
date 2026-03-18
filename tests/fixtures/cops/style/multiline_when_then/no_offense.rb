case foo
when bar then do_something
end

case foo
when bar
end

case foo
when bar
  do_something
end

case condition
when foo then {
    key: 'value'
  }
end

case foo
when bar then do_something
              do_another_thing
end

case foo
when bar,
     baz then do_something
end

# when conditions span multiple lines, `then` is allowed
case directive
when 'method', 'singleton-method',
     'attr', 'attr_accessor', 'attr_reader', 'attr_writer' then
  false
end

case request_subdomain
when 'new-york-city',
     'gulf-coast',
     'boston',
     'espana' then
  redirect_to url + request_subdomain
end

case condition
when foo then [
    'element'
  ]
end
