# nitrocop-filename: example.gemspec
Gem::Specification.new do |spec|
  spec.name = 'example'
  spec.version = '1.0'
  spec.summary = 'An example gem'
  spec.authors = ['Author']
  spec.files = Dir['lib/**/*']
  spec.homepage = 'https://example.com'
  spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  spec.metadata['changelog_uri'] = 'https://example.com/changelog'
end
