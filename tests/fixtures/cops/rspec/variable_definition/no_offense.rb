RSpec.describe Foo do
  let(:user_name) { 'Adam' }
  let(:email) { 'test@example.com' }
  let!(:count) { 42 }
  subject(:result) { described_class.new }
  let(:items) { [1, 2, 3] }
  let!(:record) { create(:record) }
end

# subject with receiver is not an RSpec call
RSpec.describe Bar do
  it 'works' do
    message.subject 'testing'
  end
end

# subject "string" outside any example group should not be flagged
# (e.g. Fabricator DSL, Mail.new configuration, etc.)
Fabricator(:incoming_email) do
  subject "Hello world"
end

Mail.new do
  subject 'testing message delivery'
end

# let with no arguments
let
