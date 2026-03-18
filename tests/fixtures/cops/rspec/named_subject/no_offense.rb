RSpec.describe User do
  subject(:user) { described_class.new }

  it "is a User" do
    expect(user).to be_a(User)
  end

  it "is valid" do
    expect(user.valid?).to be(true)
  end

  # Unnamed subject definition — `subject` reference is fine
  subject { described_class.new }
end

# is_expected and should are not bare `subject` references
RSpec.describe Widget do
  subject { described_class.new }

  it { is_expected.to be_valid }
  it { should be_valid }
end

# subject inside a def method is NOT a test subject reference
RSpec.describe Service do
  subject { described_class.new }

  def execute_job
    subject.execute(user: user.id)
  end

  it 'works' do
    expect(execute_job).to be_truthy
  end
end

# subject inside a let block is NOT an example/hook
RSpec.describe Worker do
  let(:job) { subject }

  it 'runs' do
    expect(job).to be_valid
  end
end

# RSpec.shared_examples with subject inside — IgnoreSharedExamples (default true)
RSpec.shared_examples 'a database connection' do
  it 'responds to insert' do
    expect(subject).to respond_to(:insert)
  end
end

# shared_examples_for with subject — also ignored
shared_examples_for 'a valid record' do
  it 'is valid' do
    expect(subject).to be_valid
  end
end

# shared_context is NOT ignored by IgnoreSharedExamples — only shared_examples is.
# subject in shared_context outside of an example/hook is not flagged (not in example scope)

# subject with arguments is NOT a bare subject reference
RSpec.describe Config do
  it 'passes' do
    subject(:name)
  end
end

# subject called with block arg (&b) should not be flagged — it is not a bare
# subject reference, it passes a block to subject (used with yield_control matchers)
RSpec.describe Crawler do
  subject { described_class.new }

  it "yields nothing" do
    expect { |b| subject(&b) }.not_to yield_control
  end
end
