RSpec.describe 'test' do
  it 'compares with eq' do
    expect(foo.bar).to eq(foo.bar)
    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ RSpec/IdenticalEqualityAssertion: Identical expressions on both sides of the equality may indicate a flawed test.
  end

  it 'compares with eql' do
    expect(foo.bar.baz).to eql(foo.bar.baz)
    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ RSpec/IdenticalEqualityAssertion: Identical expressions on both sides of the equality may indicate a flawed test.
  end

  it 'compares trivial constants' do
    expect(42).to eq(42)
    ^^^^^^^^^^^^^^^^^^^^ RSpec/IdenticalEqualityAssertion: Identical expressions on both sides of the equality may indicate a flawed test.
  end

  it 'compares dot vs constant path for lowercase method' do
    expect(Obj.method_name).to eq(Obj::method_name)
    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ RSpec/IdenticalEqualityAssertion: Identical expressions on both sides of the equality may indicate a flawed test.
  end

  it 'compares empty array literals' do
    expect(%i{}).to eq([])
    ^^^^^^^^^^^^^^^^^^^^^^ RSpec/IdenticalEqualityAssertion: Identical expressions on both sides of the equality may indicate a flawed test.
  end

  it 'compares regex with equivalent escapes' do
    expect(/[\§]/).to eq(/[§]/)
    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ RSpec/IdenticalEqualityAssertion: Identical expressions on both sides of the equality may indicate a flawed test.
  end
end
