# Receiver is a send node (regular method call with `.`) — RuboCop flags these
return unless foo.bar&.empty?
              ^^^^^^^^^^^^^^^ Lint/SafeNavigationWithEmpty: Avoid calling `empty?` with the safe navigation operator in conditionals.
bar if collection.find_all&.empty?
       ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Lint/SafeNavigationWithEmpty: Avoid calling `empty?` with the safe navigation operator in conditionals.
do_something if items.select&.empty?
                ^^^^^^^^^^^^^^^^^^^^^^^^ Lint/SafeNavigationWithEmpty: Avoid calling `empty?` with the safe navigation operator in conditionals.

# Receiver is a bare method call (send nil :method) — RuboCop flags these
return unless path&.empty?
              ^^^^^^^^^^^^^ Lint/SafeNavigationWithEmpty: Avoid calling `empty?` with the safe navigation operator in conditionals.
if options&.empty?
   ^^^^^^^^^^^^^^^ Lint/SafeNavigationWithEmpty: Avoid calling `empty?` with the safe navigation operator in conditionals.
  name
else
  "#<QueueConfiguration #{name} options=#{options.inspect}>"
end
