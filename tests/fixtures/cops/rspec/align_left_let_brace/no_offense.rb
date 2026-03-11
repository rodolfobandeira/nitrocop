RSpec.describe 'test' do
  let(:foo)      { bar }
  let(:hi)       { baz }
  let(:blahblah) { baz }

  let(:thing) { ignore_this }
  let(:other) {
    ignore_this_too
  }
end

# A single let after a gap (non-let line) is a singleton and never flagged,
# even if its brace column differs from adjacent groups
RSpec.describe 'scoped lets' do
  let(:account) { create(:account) }
  let(:user)    { create(:user) }

  context 'inner scope' do
    let(:reply_mail_without_uuid) { something_long }
    let(:described_subject)       { other }
    let(:email_channel)           { third }
  end
end

# let-like text inside heredocs should NOT be detected as let calls
RSpec.describe 'heredoc' do
  let(:template) { <<~RUBY }
    let(:foo) { bar }
    let(:blahblah) { baz }
  RUBY
end

# let-like text inside strings should NOT be detected
RSpec.describe 'string' do
  let(:code) { "let(:foo) { bar }\nlet(:blahblah) { baz }" }
end

# let with proc argument (no block) should NOT be detected
RSpec.describe 'proc' do
  let(:user, &args[:build_user])
end
