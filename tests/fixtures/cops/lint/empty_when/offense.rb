case foo
when 1
^^^^ Lint/EmptyWhen: Avoid empty `when` conditions.
when 2
  do_something
end
case bar
when :a
^^^^ Lint/EmptyWhen: Avoid empty `when` conditions.
when :b
^^^^ Lint/EmptyWhen: Avoid empty `when` conditions.
when :c
  handle_c
end
# Multiple consecutive empty when clauses with no comments
case render_type
when :partial, :template
  check_path(result)
when :inline
^^^^ Lint/EmptyWhen: Avoid empty `when` conditions.
when :js
^^^^ Lint/EmptyWhen: Avoid empty `when` conditions.
when :json
^^^^ Lint/EmptyWhen: Avoid empty `when` conditions.
when :text
^^^^ Lint/EmptyWhen: Avoid empty `when` conditions.
when :xml
^^^^ Lint/EmptyWhen: Avoid empty `when` conditions.
end
# Empty when before else (no comment in else body)
case frame[:type]
when :headers then event(:open)
when :priority
^^^^ Lint/EmptyWhen: Avoid empty `when` conditions.
else stream_error
end
# Empty when with sibling that has a comment body
case msg_type
when :data
  process(msg)
when :notice
^^^^ Lint/EmptyWhen: Avoid empty `when` conditions.
when :error_response
^^^^ Lint/EmptyWhen: Avoid empty `when` conditions.
when :ready_for_query
^^^^ Lint/EmptyWhen: Avoid empty `when` conditions.
when :status
  # TODO
when :alert
  handle(msg)
end
