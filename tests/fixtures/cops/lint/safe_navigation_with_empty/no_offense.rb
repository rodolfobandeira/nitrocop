return if foo.empty?
foo.empty?
bar.blank?
baz&.present?
qux&.nil?

# &.empty? outside a conditional is not flagged (only if/unless conditions)
x&.empty?
items.delete_if { |e| e.str_content&.empty? }

# Receiver is a safe navigation chain — RuboCop does not flag chained &.&.
if name&.strip&.empty?
  set_default
end

# Receiver is a local variable (lvar) — RuboCop requires (send ...) receiver
foo = get_value
return unless foo&.empty?
data = fetch_data
unless data&.empty?
  process(data)
end
