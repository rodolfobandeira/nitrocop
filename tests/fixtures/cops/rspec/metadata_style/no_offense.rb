describe 'Something', :a do
  it 'works' do
    expect(true).to eq(true)
  end
end

describe 'Something', :a, :b do
  it 'has multiple symbols' do
    expect(1).to eq(1)
  end
end

describe 'Something', a: false do
  it 'has false metadata' do
    expect(result).to be_nil
  end
end

describe 'Something', b: 1 do
  it 'has non-boolean metadata' do
    expect(value).to eq(1)
  end
end

# Hooks with symbol metadata are fine
before(:each, :fast) do
end

# Calls without blocks should not be flagged
describe 'Something', a: true

# String key metadata is not flagged
describe 'Something', 'a' => true do
end

# Non-symbol-key hash metadata is not flagged
describe 'Something', a => true do
end

# Block argument (not a real block) should not be flagged
it 'has metadata', &(proc do end)
