RSpec.describe 'test' do
  it 'flags block.call' do
    allow(foo).to receive(:bar) { |&block| block.call }
                                ^^^^^^^^^^^^^^^^^^^^^^^ RSpec/Yield: Use `.and_yield`.
  end

  it 'flags block.call with args' do
    allow(foo).to receive(:baz) { |&block| block.call(1, 2) }
                                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ RSpec/Yield: Use `.and_yield`.
  end

  it 'flags chained receive' do
    allow(foo).to receive(:qux).with(anything) { |&block| block.call }
                                               ^^^^^^^^^^^^^^^^^^^^^^^ RSpec/Yield: Use `.and_yield`.
  end

  it 'flags do-end block on .to with receive as argument' do
    allow(Bundler).to receive(:with_original_env) do |&block|
                                                  ^^^^^^^^^^^ RSpec/Yield: Use `.and_yield`.
      block.call
    end
  end

  it 'flags do-end block with different block param name' do
    allow(obj).to receive(:run) do |&blk|
                                ^^^^^^^^^ RSpec/Yield: Use `.and_yield`.
      blk.call
    end
  end

  it 'flags multiple block.call in do-end' do
    allow(foo).to receive(:bar) do |&block|
                                ^^^^^^^^^^^ RSpec/Yield: Use `.and_yield`.
      block.call
      block.call
    end
  end
end
