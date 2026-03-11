describe 'non-indexed lets' do
  let(:user) { create(:user) }
  let(:admin) { create(:admin) }
  let(:first_item) { create(:item) }
  let(:last_item) { create(:item) }
  let(:primary_account) { create(:account) }
  let(:secondary_account) { create(:account) }
end

# Single indexed let without a matching base is OK (group size = 1 <= Max)
describe 'single indexed let' do
  let(:target_account) { create(:account) }
  let(:target_account2) { create(:account) }
end

# Names with an index-like suffix that aren't actually trailing (no trailing digits)
context 'index-like with suffix' do
  let(:user_7_day_average) { 700 }
  let(:user_30_day_average) { 3000 }
end

# Names with different prefixes after digit stripping
describe 'different prefixes' do
  let(:item_1) { create(:item) }
  let(:foo_item_1) { create(:item) }
end
