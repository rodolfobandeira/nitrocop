x.blank?
x.present?
!x.empty?
x.nil?
name.present? && name.length > 0
x.nil? || y.empty?
x.nil? && x.empty?
x.nil? || x.zero?
something if foo.present?
something unless foo.blank?
def blank?
  !present?
end
unless foo.present?
  something
else
  something_else
end

# present? called with argument (class method style) should NOT be flagged
# RuboCop's NodePattern `(send (send $_ :present?) :!)` requires present? with no arguments
!Helpers.present?(value)
!Vagrant::Util::Presence.present?(directory)
unless Helpers.present?(value)
  do_something
end

# safe navigation on present?/empty? — RuboCop's NodePattern matches send not csend
# so &.present? and &.empty? should NOT be flagged
return [] unless response&.strip&.present?
unless object&.present?
  do_something
end
foo.nil? || foo&.empty?

# pattern match guard: `in pattern unless condition` is not a regular unless
# RuboCop's on_if handler does not visit pattern match guards
case element.name
in "div" unless element.at("div").present?
  element.name = "p"
end
