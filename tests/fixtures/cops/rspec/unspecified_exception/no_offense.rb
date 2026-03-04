RSpec.describe User do
  it 'allows exception class' do
    expect { raise StandardError }.to raise_error(StandardError)
  end

  it 'allows exception message' do
    expect { raise StandardError.new('error') }.to raise_error('error')
  end

  it 'allows not_to raise_error without args' do
    expect { safe_method }.not_to raise_error
  end

  it 'allows raise_error with block' do
    expect { raise StandardError }.to raise_error { |e| e.data }
  end

  it 'allows raise_exception with class' do
    expect { raise StandardError }.to raise_exception(StandardError)
  end

  it 'allows to_not raise_error without args' do
    expect { safe_method }.to_not raise_error
  end

  # do/end block on .to — the block has params so exception is handled
  it 'allows raise_error with do/end block args' do
    expect { raise StandardError }.to raise_error do |error|
      expect(error).to be_a(StandardError)
    end
  end

  # Parens form expect(...) should not be flagged — only block form expect { }
  it 'allows expect(...).to raise_error' do
    expect(run_assertions('assert_match("blah")', result)).to raise_error
  end

  it 'allows expect(...).to raise_exception' do
    expect(some_method_call).to raise_exception
  end
end
