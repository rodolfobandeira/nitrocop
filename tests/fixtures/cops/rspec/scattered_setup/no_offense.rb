describe Foo do
  before { bar }
  after { baz }
  around { |t| t.run }

  it { expect(true).to be(true) }
end

describe Bar do
  before { setup }

  describe '.baz' do
    before { more_setup }
    it { expect(1).to eq(1) }
  end
end

# before :all and before :each (default) are different scope types
describe Qux do
  before :all do
    setup_once
  end

  before do
    setup_each
  end

  it { expect(true).to eq(true) }
end

# Hooks with different metadata should not be flagged
describe MetadataExample do
  before(:each, :unix_only) do
    setup_unix
  end

  before(:each) do
    setup_normal
  end

  it { expect(true).to eq(true) }
end

# Hooks with different metadata (symbol vs none)
describe MetadataExample2 do
  before(:example) { foo }
  before(:example, :special_case) { bar }

  it { expect(true).to eq(true) }
end

# after hooks with different scopes (explicit :each vs no arg)
describe AfterScopeExample do
  after do
    cleanup_general
  end

  after(:all) do
    cleanup_once
  end

  it { expect(true).to eq(true) }
end

# Hooks with different keyword metadata values
describe KeywordMetadata do
  before(:example, special_case: true) { bar }
  before(:example, special_case: false) { baz }

  it { expect(true).to eq(true) }
end
