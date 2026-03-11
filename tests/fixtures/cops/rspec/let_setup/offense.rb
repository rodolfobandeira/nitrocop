describe Foo do
  let!(:foo) { bar }
  ^^^^^^^^^^ RSpec/LetSetup: Do not use `let!` to setup objects not referenced in tests.

  it 'does not use foo' do
    expect(baz).to eq(qux)
  end
end

describe Foo do
  context 'when something special happens' do
    let!(:foo) { bar }
    ^^^^^^^^^^ RSpec/LetSetup: Do not use `let!` to setup objects not referenced in tests.

    it 'does not use foo' do
      expect(baz).to eq(qux)
    end
  end

  it 'references some other foo' do
    foo
  end
end

describe Foo do
  let!(:bar) { baz }
  ^^^^^^^^^^ RSpec/LetSetup: Do not use `let!` to setup objects not referenced in tests.
end

# include_examples block with unused let!
describe Widget do
  include_examples 'shared behavior' do
    let!(:item) { create(:item) }
    ^^^^^^^^^^ RSpec/LetSetup: Do not use `let!` to setup objects not referenced in tests.

    it 'works' do
      expect(true).to be true
    end
  end
end

# include_context block with unused let!
describe Widget do
  include_context 'with setup' do
    let!(:record) { create(:record) }
    ^^^^^^^^^^ RSpec/LetSetup: Do not use `let!` to setup objects not referenced in tests.

    it 'works' do
      expect(true).to be true
    end
  end
end

# RSpec.describe with unused let!
RSpec.describe Widget do
  let!(:item) { create(:item) }
  ^^^^^^^^^^ RSpec/LetSetup: Do not use `let!` to setup objects not referenced in tests.

  it 'does not use item' do
    expect(true).to be true
  end
end
