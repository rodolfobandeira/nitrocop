RSpec.describe User do
  subject { described_class.new }

  it "is valid" do
    expect(subject.valid?).to be(true)
           ^^^^^^^ RSpec/NamedSubject: Name your test subject if you need to reference it explicitly.
  end

  specify do
    expect(subject.valid?).to be(true)
           ^^^^^^^ RSpec/NamedSubject: Name your test subject if you need to reference it explicitly.
  end

  before(:each) do
    do_something_with(subject)
                      ^^^^^^^ RSpec/NamedSubject: Name your test subject if you need to reference it explicitly.
  end

  # subject { ... } inside a hook is a reference, not a definition
  around(:each) do |example|
    subject { Doorkeeper.configuration }
    ^^^^^^^ RSpec/NamedSubject: Name your test subject if you need to reference it explicitly.
    example.run
  end

  after do
    do_something_with(subject)
                      ^^^^^^^ RSpec/NamedSubject: Name your test subject if you need to reference it explicitly.
  end

  # subject inside a block within an example is still flagged
  it "does not raise" do
    expect { subject }.not_to raise_error
             ^^^^^^^ RSpec/NamedSubject: Name your test subject if you need to reference it explicitly.
  end

  # prepend_before is also a hook
  prepend_before do
    setup(subject)
          ^^^^^^^ RSpec/NamedSubject: Name your test subject if you need to reference it explicitly.
  end

  # def subject.method_name — the `subject` receiver is a test subject reference
  it "overrides behavior" do
    def subject.custom_method
        ^^^^^^^ RSpec/NamedSubject: Name your test subject if you need to reference it explicitly.
      true
    end
    subject.custom_method
    ^^^^^^^ RSpec/NamedSubject: Name your test subject if you need to reference it explicitly.
  end
end

# `it` blocks inside helper methods — subject inside them should be flagged
def self.it_should_have_view(key, value)
  it "should have #{value} for view key '#{key}'" do
    expect(subject.send(key)).to eq value
           ^^^^^^^ RSpec/NamedSubject: Name your test subject if you need to reference it explicitly.
  end
end

# shared_context is NOT a shared example group for IgnoreSharedExamples purposes.
# RuboCop's `shared_example?` matcher only matches SharedGroups.examples
# (shared_examples, shared_examples_for), not SharedGroups.context (shared_context).
# So subject inside shared_context examples IS flagged even with IgnoreSharedExamples: true.
RSpec.describe Config do
  subject { described_class.new }

  shared_context "with setup" do
    it "succeeds" do
      expect(subject.status).to eq(200)
             ^^^^^^^ RSpec/NamedSubject: Name your test subject if you need to reference it explicitly.
    end
  end
end
