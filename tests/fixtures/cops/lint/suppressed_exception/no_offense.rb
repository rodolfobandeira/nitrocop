begin
  do_something
rescue => e
  handle(e)
end
begin
  work
rescue StandardError
  retry
end
# AllowComments: rescue with comment is allowed by default
begin
  do_something
rescue
  # Intentionally ignored
end
begin
  work
rescue
  # Expected to fail sometimes
end
# AllowComments: rescue with comment inside def (implicit begin)
def perform
  do_work
rescue StandardError
  # Intentionally suppressed
end
def process
  do_work
rescue
  # Known to fail occasionally
end
def execute
  do_work
rescue => e
  # Log elsewhere
end
# AllowComments: trailing comment on rescue line itself
begin
  do_something
rescue # intentionally ignored
end
begin
  do_something
rescue StandardError # intentionally ignored
end
def perform_task
  do_work
rescue RuntimeError # skip
end
