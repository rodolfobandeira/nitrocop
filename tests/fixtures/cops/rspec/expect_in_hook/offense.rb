before do
  expect(something).to eq('foo')
  ^^^^^^ RSpec/ExpectInHook: Do not use `expect` in `before` hook
end
after do
  is_expected.to eq('bar')
  ^^^^^^^^^^^ RSpec/ExpectInHook: Do not use `is_expected` in `after` hook
end
around do
  expect_any_instance_of(Something).to receive(:foo)
  ^^^^^^^^^^^^^^^^^^^^^^ RSpec/ExpectInHook: Do not use `expect_any_instance_of` in `around` hook
end
before do
  expect { something }.to eq('foo')
  ^^^^^^ RSpec/ExpectInHook: Do not use `expect` in `before` hook
end
before do
  if condition
    expect(something).to eq('bar')
    ^^^^^^ RSpec/ExpectInHook: Do not use `expect` in `before` hook
  end
end
after do
  items.each do |item|
    expect(item).to be_valid
    ^^^^^^ RSpec/ExpectInHook: Do not use `expect` in `after` hook
  end
end
before do
  def check_result(result)
    expect(result).to be_valid
    ^^^^^^ RSpec/ExpectInHook: Do not use `expect` in `before` hook
  end
end
before do
  @validator = lambda do |val|
    expect(val).to be_present
    ^^^^^^ RSpec/ExpectInHook: Do not use `expect` in `before` hook
  end
end
before do
  @items = (0..4).map do
    double("item").tap do |item|
      expect(item).to receive(:call)
      ^^^^^^ RSpec/ExpectInHook: Do not use `expect` in `before` hook
    end
  end
end
before(:each) do
  should_receive(:response_body).and_return @body
  ^^^^^^^^^^^^^^ RSpec/ExpectInHook: Do not use `should_receive` in `before` hook
end
after do
  should_not_receive(:cleanup)
  ^^^^^^^^^^^^^^^^^^ RSpec/ExpectInHook: Do not use `should_not_receive` in `after` hook
end
