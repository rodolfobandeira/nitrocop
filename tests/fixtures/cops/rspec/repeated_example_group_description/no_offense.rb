describe 'doing x' do
  it { something }
end

describe 'doing y' do
  it { other }
end

context do
  it { thing }
end

context do
  it { other_thing }
end

# skip/pending inside block should be excluded from duplicate checking
describe 'repeated feature' do
  skip 'not implemented yet'
end

describe 'repeated feature' do
  pending 'work in progress'
end

# Different metadata args make descriptions unique
RSpec.describe 'Animal', 'dog' do
  it { is_mammal }
end

RSpec.describe 'Animal', 'cat' do
  it { is_mammal }
end

# Different classes count as different descriptions
context A::B do
  it { works }
end

context C::D do
  it { also_works }
end
