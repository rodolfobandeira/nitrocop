# nitrocop-filename: example.gemspec
Gem::Specification.new do |spec|
  spec.name = 'example'
  spec.version = '1.0'
  spec.name = 'other'
       ^^^^ Gemspec/DuplicatedAssignment: Attribute `name` is already set on line 2.
  spec.summary = 'Summary'
  spec.summary = 'Other summary'
       ^^^^^^^ Gemspec/DuplicatedAssignment: Attribute `summary` is already set on line 5.
  spec.version = '2.0'
       ^^^^^^^ Gemspec/DuplicatedAssignment: Attribute `version` is already set on line 3.
  spec.description = spec.description = 'self-assign'
       ^^^^^^^^^^^ Gemspec/DuplicatedAssignment: Attribute `description` is already set on line 8.
  spec.metadata['rubygems_mfa_required'] = 'true'
  spec.metadata['rubygems_mfa_required'] = 'false'
       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Gemspec/DuplicatedAssignment: Attribute `metadata['rubygems_mfa_required']` is already set on line 9.
end
