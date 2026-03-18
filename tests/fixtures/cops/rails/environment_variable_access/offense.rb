ENV['SECRET_KEY']
^^^ Rails/EnvironmentVariableAccess: Do not read from `ENV` directly post initialization.
ENV["DATABASE_URL"]
^^^ Rails/EnvironmentVariableAccess: Do not read from `ENV` directly post initialization.
ENV.fetch('REDIS_URL')
^^^ Rails/EnvironmentVariableAccess: Do not read from `ENV` directly post initialization.
::ENV.fetch('API_KEY')
^^^^^ Rails/EnvironmentVariableAccess: Do not read from `ENV` directly post initialization.
ENV['FOO'] = 'bar'
^^^ Rails/EnvironmentVariableAccess: Do not write to `ENV` directly post initialization.
::ENV['QUX'] = 'val'
^^^^^ Rails/EnvironmentVariableAccess: Do not write to `ENV` directly post initialization.
ENV.store('KEY', 'value')
^^^ Rails/EnvironmentVariableAccess: Do not read from `ENV` directly post initialization.
ENV.delete('KEY')
^^^ Rails/EnvironmentVariableAccess: Do not read from `ENV` directly post initialization.
