describe 'test' do; end
context 'test' do; end
it 'test' do; end
example 'test' do; end
specify do; end
feature 'test' do; end

# :skip symbol as a matcher argument should not be flagged
it 'returns skip action' do
  expect(applier.action).to eq(:skip)
end

# :pending symbol as a matcher argument should not be flagged
it 'returns pending status' do
  expect(result.status).to eq(:pending)
end

# skip: keyword in non-RSpec method call should not be flagged
create(:record, skip: true)
