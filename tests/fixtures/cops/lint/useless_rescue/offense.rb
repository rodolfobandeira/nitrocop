def foo
  do_something
rescue
^^^^^^ Lint/UselessRescue: Useless `rescue` detected.
  raise
end

def bar
  do_something
rescue => e
^^^^^^ Lint/UselessRescue: Useless `rescue` detected.
  raise e
end

def baz
  do_something
rescue
^^^^^^ Lint/UselessRescue: Useless `rescue` detected.
  raise $!
end

raise "TEST_ME" rescue raise rescue nil
# nitrocop-expect: 19:16 Lint/UselessRescue: Useless `rescue` detected.
