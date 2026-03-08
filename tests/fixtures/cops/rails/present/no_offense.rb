x.present?
x.blank?
!x.empty?
x.nil?
name.present? && name.valid?

# unless blank? with else clause should NOT be flagged
# (Style/UnlessElse handles these; RuboCop skips them)
unless foo.blank?
  do_something
else
  do_other
end

unless user.name.blank?
  greet(user)
else
  ask_name
end
