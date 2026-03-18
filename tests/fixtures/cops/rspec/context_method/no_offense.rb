describe '.foo_bar' do
end

describe '#foo_bar' do
end

context "when it's sunny" do
end

context 'with valid input' do
end

# context without a block should not be flagged (RuboCop uses on_block)
context ".some_method"

# context with receiver should not be flagged
SomeClass.context ".some_method" do
end
