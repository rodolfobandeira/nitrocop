badVariable = 1
^^^^^^^^^^^ Naming/VariableName: Use snake_case for variable names.

myValue = 2
^^^^^^^ Naming/VariableName: Use snake_case for variable names.

firstName = "John"
^^^^^^^^^ Naming/VariableName: Use snake_case for variable names.

@badVariable = 1
^^^^^^^^^^^^ Naming/VariableName: Use snake_case for variable names.

@myValue = 2
^^^^^^^^ Naming/VariableName: Use snake_case for variable names.

@@badVariable = 1
^^^^^^^^^^^^^ Naming/VariableName: Use snake_case for variable names.

$badVariable = 1
^^^^^^^^^^^^ Naming/VariableName: Use snake_case for variable names.

def foo(badParam)
        ^^^^^^^^ Naming/VariableName: Use snake_case for variable names.
end

def bar(ok, badName:)
            ^^^^^^^^ Naming/VariableName: Use snake_case for variable names.
end
