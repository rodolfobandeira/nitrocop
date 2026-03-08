pending 'reason'
skip 'reason'
it 'does something', pending: 'reason' do
end
it 'does something', skip: 'reason' do
end
describe 'something', pending: 'reason' do
end

RSpec.describe Foo do
  it 'does something' do
    next skip
  end
end

RSpec.xdescribe 'something' do
end
