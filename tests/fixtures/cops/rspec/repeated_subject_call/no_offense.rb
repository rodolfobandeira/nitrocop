RSpec.describe Foo do
  it do
    expect(subject.a).to eq(3)
    expect(subject.b).to eq(4)
  end
end

RSpec.describe Bar do
  it do
    expect { subject }.to change { Bar.count }
    expect(subject.b).to eq(4)
  end
end

# Chained subject calls are not flagged (subject is a receiver)
RSpec.describe Baz do
  it do
    expect(subject.reblogs_count).to eq(1)
    expect { subject.destroy }.to_not raise_error
  end
end

# subject as argument to expect() — parent is a send node, not flagged
RSpec.describe Qux do
  it "allows voting" do
    expect(subject).not_to be_allowed(some_resource)
    other_resources.each do |resource|
      expect(subject).to be_allowed(resource)
    end
  end
end

# subject as argument inside blocks should not be flagged
RSpec.describe Quux do
  it "checks results" do
    expect(subject).to eq(expected)
    items.each do |item|
      expect(subject).to include(item)
    end
  end
end

# subject as argument to create/other methods inside expect blocks
RSpec.describe Corge do
  it do
    expect { create(:item, owner: subject) }.to change { Item.count }
    expect { create(:item, subject) }.to not_change { Item.count }
  end
end

# Different named subjects — each used once is not an offense
RSpec.describe Grault do
  subject { do_something_else }
  subject(:bar) { do_something }

  it do
    expect { bar }.to not_change { Grault.count }
    expect { subject }.to not_change { Grault.count }
  end
end
