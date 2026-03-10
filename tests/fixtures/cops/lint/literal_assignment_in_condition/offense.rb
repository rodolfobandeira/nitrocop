if x = 42
   ^^^^^^ Lint/LiteralAssignmentInCondition: Don't use literal assignment `= 42` in conditional, should be `==` or non-literal operand.
  do_something
end

if y = true
   ^^^^^^^^ Lint/LiteralAssignmentInCondition: Don't use literal assignment `= true` in conditional, should be `==` or non-literal operand.
  do_something
end

while z = "hello"
      ^^^^^^^^^^^ Lint/LiteralAssignmentInCondition: Don't use literal assignment `= "hello"` in conditional, should be `==` or non-literal operand.
  do_something
end

if values = []
   ^^^^^^^^^^^ Lint/LiteralAssignmentInCondition: Don't use literal assignment `= []` in conditional, should be `==` or non-literal operand.
  do_something
end

if values = [1, 2, 3]
   ^^^^^^^^^^^^^^^^^^ Lint/LiteralAssignmentInCondition: Don't use literal assignment `= [1, 2, 3]` in conditional, should be `==` or non-literal operand.
  do_something
end

if options = {}
   ^^^^^^^^^^^^ Lint/LiteralAssignmentInCondition: Don't use literal assignment `= {}` in conditional, should be `==` or non-literal operand.
  do_something
end

if options = { foo: :bar }
   ^^^^^^^^^^^^^^^^^^^^^^^ Lint/LiteralAssignmentInCondition: Don't use literal assignment `= { foo: :bar }` in conditional, should be `==` or non-literal operand.
  do_something
end

if validate(resource) { hashed = true; valid_password?(password) }
                        ^^^^^^^^^^^^^ Lint/LiteralAssignmentInCondition: Don't use literal assignment `= true` in conditional, should be `==` or non-literal operand.
  do_something
end

if File.exist?(path = "./.sprocketsrc")
               ^^^^^^^^^^^^^^^^^^^^^^^^ Lint/LiteralAssignmentInCondition: Don't use literal assignment `= "./.sprocketsrc"` in conditional, should be `==` or non-literal operand.
  do_something
end

if (count = 0) == 0
    ^^^^^^^^^ Lint/LiteralAssignmentInCondition: Don't use literal assignment `= 0` in conditional, should be `==` or non-literal operand.
  do_something
end

if !(0..5).include?(count = 0)
                    ^^^^^^^^^ Lint/LiteralAssignmentInCondition: Don't use literal assignment `= 0` in conditional, should be `==` or non-literal operand.
  do_something
end
