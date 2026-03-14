RSpec.describe Foo do
  let('user_name') { 'Adam' }
      ^^^^^^^^^^^ RSpec/VariableDefinition: Use symbols for variable names.
  let('email') { 'test@example.com' }
      ^^^^^^^ RSpec/VariableDefinition: Use symbols for variable names.
  let!('count') { 42 }
       ^^^^^^^ RSpec/VariableDefinition: Use symbols for variable names.
end

# Mail DSL subject with string arg inside an example group IS flagged
RSpec.describe Bar do
  it 'sends email' do
    Mail.new do
      subject 'testing message delivery'
              ^^^^^^^^^^^^^^^^^^^^^^^^^^ RSpec/VariableDefinition: Use symbols for variable names.
    end
  end
end
