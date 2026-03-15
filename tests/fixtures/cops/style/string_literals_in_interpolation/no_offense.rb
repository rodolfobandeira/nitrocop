"result is #{x == 'foo'}"
"hello #{hash['key']}"
"test #{y.gsub('a', 'b')}"
"plain string"
'single quoted'
x = "#{42}"
# Double-quoted strings with embedded single quotes need double quotes
"'#{elements.join("', '")}'"
# Strings inside %x() / backtick interpolation should not be flagged
%x( createdb #{config["arunit"]["database"]} )
%x( dropdb --if-exists #{config["arunit2"]["database"]} )
`#{File.expand_path("../../exe/rails", __dir__)} new --help`
`cd #{repo_dir} && git init . #{"--initial-branch=main" if supported}`
