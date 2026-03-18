# nitrocop-filename: spec/entities/collection.rb
# nitrocop-expect: 1:0 RSpec/SpecFilePathSuffix: Spec path should end with `_spec.rb`.
module Specs
  module Entities
    describe Collection do
      it 'works' do
        expect(true).to eq(true)
      end
    end
  end
end
