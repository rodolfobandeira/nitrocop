if something
  do_work
end
unless something
  do_work
end
if x
  y
else
  z
end
# AllowComments: true (default) — comment-only bodies are OK
if condition
  # TODO: handle this case
end
unless condition
  # Not yet implemented
end
if something
  # Intentionally empty for now
else
  fallback
end
# Single-line conditionals with empty bodies (RuboCop skips same-line if/end)
if true then ; end.should == nil
if false then ; end.should == nil
unless true; end.should == nil
if 1;end
if 1; end
# Comment inside a complex predicate (begin..rescue..end in condition)
if first_check
  do_something
elsif second_check &&
      begin
        process
      rescue StandardError
        # Silently ignore errors
      end
end
