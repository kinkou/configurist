# frozen_string_literal: true

require_relative 'lib/configurist/version'

Gem::Specification.new do |spec|
  spec.name = 'configurist'
  spec.version = Configurist::VERSION
  spec.license = 'MIT'

  spec.authors = ['Sergey Konotopov']
  spec.email = 'sergey.konotopov@gmail.com'

  spec.summary = 'Persisted, schema-based, overridable settings for Rails models'
  spec.description = 'Lets you attach persisted settings hierarchies defined by JSONSchema to arbitrary Rails models'

  spec.homepage = 'https://github.com/kinkou/configurist'
  spec.metadata = {
    'allowed_push_host' => 'https://rubygems.org',
    'homepage_uri' => spec.homepage,
    'source_code_uri' => spec.homepage,
    'changelog_uri' => "#{spec.homepage}/CHANGELOG.md",
    'rubygems_mfa_required' => 'true'
  }

  spec.files = Dir['lib/**/*.rb']
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 3.2'
end
