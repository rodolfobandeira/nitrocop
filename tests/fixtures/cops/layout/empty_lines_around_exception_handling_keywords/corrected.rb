begin
  do_something
rescue
  handle_error
end

begin
  something
ensure
  cleanup
end

begin
  recover
rescue=>e
  handle_error
end
