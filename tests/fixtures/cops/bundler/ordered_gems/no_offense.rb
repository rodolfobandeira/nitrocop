gem 'alpha'
gem 'beta'
gem 'gamma'

gem 'zoo'
gem 'zulu'

gem 'rubocop'
gem ENV['RABL_GEM'] || 'rabl'
gem 'ast'

gem 'alpha'
=begin
gem 'zoo'
gem 'aardvark'
=end
gem 'beta'

gem 'alpha',
  git: 'https://example.com/alpha'
gem 'beta',
  git: 'https://example.com/beta'
gem 'gamma'

platforms :jruby do
  gem "activerecord-jdbc-adapter",
    git: "https://github.com/jruby/activerecord-jdbc-adapter",
    glob: "activerecord-jdbc-adapter.gemspec"
  gem "activerecord-jdbcmysql-adapter",
    git: "https://github.com/jruby/activerecord-jdbc-adapter",
    glob: "activerecord-jdbcmysql-adapter.gemspec"
  gem "activerecord-jdbcsqlite3-adapter",
    git: "https://github.com/jruby/activerecord-jdbc-adapter",
    glob: "activerecord-jdbcsqlite3-adapter.gemspec"
end
