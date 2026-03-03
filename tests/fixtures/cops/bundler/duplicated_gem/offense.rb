source 'https://rubygems.org'
gem 'rubocop'
gem 'rubocop'
^^^^^^^^^^^^^ Bundler/DuplicatedGem: Gem `rubocop` requirements already given on line 2 of the Gemfile.

gem 'rails'
gem 'puma'
gem 'rails'
^^^^^^^^^^^ Bundler/DuplicatedGem: Gem `rails` requirements already given on line 5 of the Gemfile.

gem 'nokogiri', '~> 1.0'
gem 'nokogiri'
^^^^^^^^^^^^^^ Bundler/DuplicatedGem: Gem `nokogiri` requirements already given on line 9 of the Gemfile.

# Nested if inside else of an if/elsif chain should be a separate conditional
if ENV['RAILS'] >= "8.0"
  gem 'sqlite3', '~> 2.1'
elsif ENV['RAILS'] >= "7.1"
  gem 'sqlite3', '~> 1.7'
else
  if ENV['RAILS'] >= "6.0"
    gem 'sqlite3', '~> 1.4'
  else
    gem 'sqlite3', '~> 1.3'
  end
end
# nitrocop-expect: 16:2 Bundler/DuplicatedGem: Gem `sqlite3` requirements already given on line 14 of the Gemfile.
# nitrocop-expect: 19:4 Bundler/DuplicatedGem: Gem `sqlite3` requirements already given on line 14 of the Gemfile.
# nitrocop-expect: 21:4 Bundler/DuplicatedGem: Gem `sqlite3` requirements already given on line 14 of the Gemfile.
