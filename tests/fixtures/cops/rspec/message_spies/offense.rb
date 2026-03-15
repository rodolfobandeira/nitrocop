expect(foo).to receive(:bar)
               ^^^^^^^ RSpec/MessageSpies: Prefer `have_received` for setting message expectations. Setup the object as a spy using `allow` or `instance_spy`.
expect(foo).not_to receive(:bar)
                   ^^^^^^^ RSpec/MessageSpies: Prefer `have_received` for setting message expectations. Setup the object as a spy using `allow` or `instance_spy`.
expect(foo).to_not receive(:baz)
                   ^^^^^^^ RSpec/MessageSpies: Prefer `have_received` for setting message expectations. Setup the object as a spy using `allow` or `instance_spy`.
expect(foo).to receive(:bar).with(:baz)
               ^^^^^^^ RSpec/MessageSpies: Prefer `have_received` for setting message expectations. Setup the object as a spy using `allow` or `instance_spy`.
expect(foo).to receive(:bar).at_most(42).times
               ^^^^^^^ RSpec/MessageSpies: Prefer `have_received` for setting message expectations. Setup the object as a spy using `allow` or `instance_spy`.
expect(foo).to receive(:bar).and receive(:baz)
               ^^^^^^^ RSpec/MessageSpies: Prefer `have_received` for setting message expectations. Setup the object as a spy using `allow` or `instance_spy`.
                                 ^^^^^^^ RSpec/MessageSpies: Prefer `have_received` for setting message expectations. Setup the object as a spy using `allow` or `instance_spy`.
