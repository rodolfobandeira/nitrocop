source 'https://rubygems.org'

# Style-guide enforcer.
gem 'rubocop'

gem 'rails' # Web framework
# HTTP client
gem 'faraday'

=begin
gem 'legacy'
=end

# Non-literal gem names should not be flagged
gem db_gem, get_env("DB_GEM_VERSION")
gem plugin_name, :git => "https://example.com"
gem "social_stream-#{ g }"
gem ENV.fetch('MODEL_PARSER', nil)
gem tty_gem["name"], tty_gem["version"]
