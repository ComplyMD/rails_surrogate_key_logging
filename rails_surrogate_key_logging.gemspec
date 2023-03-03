# frozen_string_literal: true

$LOAD_PATH << File.join(File.dirname(__FILE__), 'lib')
require 'surrogate_key_logging/version'

Gem::Specification.new do |s|
  s.name        = 'rails_surrogate_key_logging'
  s.version     = SurrogateKeyLogging::VERSION
  s.authors     = ['Taylor Yelverton']
  s.email       = 'rubygems@yelvert.io'
  s.homepage    = 'https://github.com/ComplyMD/rails_surrogate_key_logging'
  s.summary     = ''
  s.license     = 'MIT'
  s.description = ''
  s.metadata    = {
    'bug_tracker_uri' => 'https://github.com/ComplyMD/rails_surrogate_key_logging/issues',
    'changelog_uri' => 'https://github.com/ComplyMD/rails_surrogate_key_logging/commits/master',
    'documentation_uri' => 'https://github.com/ComplyMD/rails_surrogate_key_logging/wiki',
    'homepage_uri' => 'https://github.com/ComplyMD/rails_surrogate_key_logging',
    'source_code_uri' => 'https://github.com/ComplyMD/rails_surrogate_key_logging',
    'rubygems_mfa_required' => 'true',
  }

  s.files = Dir['app/**/*', 'lib/**/*', 'config/**/*', 'db/**/*', 'README.md', 'MIT-LICENSE', 'rails_surrogate_key_logging.gemspec']

  s.require_paths = %w[ lib ]

  s.required_ruby_version = '>= 2.7.0'

  s.add_dependency('actionpack', '>= 6.0.0', '< 7.0.0')
  s.add_dependency('activerecord', '>= 6.0.0', '< 7.0.0')
  s.add_dependency('activesupport', '>= 6.0.0', '< 7.0.0')
  s.add_dependency('railties', '>= 6.0.0', '< 7.0.0')
end
