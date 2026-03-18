RSpec.describe User do
  let(:params) { foo }

  subject { described_class.new }
  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ RSpec/LeadingSubject: Declare `subject` above any other `let` declarations.
end

RSpec.describe Post do
  before { setup }

  subject { described_class.new }
  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ RSpec/LeadingSubject: Declare `subject` above any other `before` declarations.
end

RSpec.describe Comment do
  it { is_expected.to be_present }

  subject { described_class.new }
  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ RSpec/LeadingSubject: Declare `subject` above any other `it` declarations.
end

shared_examples 'sortable' do
  let(:records) { create_list(:record, 3) }

  subject { described_class.new }
  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ RSpec/LeadingSubject: Declare `subject` above any other `let` declarations.
end

shared_context 'with authentication' do
  before { sign_in(user) }

  subject { described_class.new }
  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ RSpec/LeadingSubject: Declare `subject` above any other `before` declarations.
end

RSpec.describe User do
  describe '#valid?' do
    let(:params) { foo }

    subject { described_class.new }
    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ RSpec/LeadingSubject: Declare `subject` above any other `let` declarations.
  end
end

RSpec.describe User do
  shared_examples_for 'a model' do
    it { is_expected.to be_present }
  end

  subject { described_class.new }
  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ RSpec/LeadingSubject: Declare `subject` above any other `shared_examples_for` declarations.
end

RSpec.describe User do
  let!(:record) { create(:record) }

  subject! { described_class.new }
  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ RSpec/LeadingSubject: Declare `subject` above any other `let!` declarations.
end

RSpec.describe User do
  it_behaves_like 'sortable' do
    let(:params) { foo }

    subject { described_class.new }
    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ RSpec/LeadingSubject: Declare `subject` above any other `let` declarations.
  end
end

RSpec.describe User do
  include_context 'with setup' do
    before { setup }

    subject { described_class.new }
    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ RSpec/LeadingSubject: Declare `subject` above any other `before` declarations.
  end
end

RSpec.describe User do
  with_feature_flag(:new_ui) do
    let(:params) { foo }

    subject { described_class.new }
    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ RSpec/LeadingSubject: Declare `subject` above any other `let` declarations.
  end
end

RSpec.describe User do
  custom_setup do
    before { setup }

    subject { described_class.new }
    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ RSpec/LeadingSubject: Declare `subject` above any other `before` declarations.
  end
end

RSpec.describe User do
  let(:user, &args[:build_user])

  subject { described_class.new }
  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ RSpec/LeadingSubject: Declare `subject` above any other `let` declarations.
end

RSpec.shared_examples_for 'a model' do
  let(:params) { foo }

  subject { described_class.new }
  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ RSpec/LeadingSubject: Declare `subject` above any other `let` declarations.
end

RSpec.shared_context 'with setup' do
  before { setup }

  subject { described_class.new }
  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ RSpec/LeadingSubject: Declare `subject` above any other `before` declarations.
end

RSpec.feature 'User management' do
  let(:admin) { create(:admin) }

  subject { described_class.new }
  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ RSpec/LeadingSubject: Declare `subject` above any other `let` declarations.
end

RSpec.describe User do
  items.each do |item|
    context "with #{item}" do
      let(:record) { create(:record, item: item) }

      subject { described_class.new }
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ RSpec/LeadingSubject: Declare `subject` above any other `let` declarations.
    end
  end
end

RSpec.describe User do
  include_context 'shared setup'

  subject { described_class.new }
  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ RSpec/LeadingSubject: Declare `subject` above any other `include_context` declarations.
end

RSpec.describe User do
  it_behaves_like 'sortable'

  subject { described_class.new }
  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ RSpec/LeadingSubject: Declare `subject` above any other `it_behaves_like` declarations.
end
