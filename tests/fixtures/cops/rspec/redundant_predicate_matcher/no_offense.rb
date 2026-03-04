expect(foo).to all(bar)
expect(foo).to cover(bar)
expect(foo).to end_with(bar)
expect(foo).to include(bar)
expect(foo).to eql(bar)
expect(foo).to be_match
# be_exist/be_exists without arguments are not redundant (different semantics from `exist`)
expect(foo).to be_exist
expect(foo).not_to be_exist
expect(foo).to be_exists
expect(foo).not_to be_exists
# other matchers without arguments are not redundant
expect(foo).to be_cover
expect(foo).to be_end_with
expect(foo).to be_eql
expect(foo).to be_equal
expect(foo).to be_include
expect(foo).to be_respond_to
expect(foo).to be_start_with
