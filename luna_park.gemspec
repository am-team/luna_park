# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'luna_park/version'

Gem::Specification.new do |spec|
  spec.name          = 'luna_park'
  spec.version       = LunaPark::VERSION
  spec.authors       = ['Alexander Kudrin', 'Philip Sorokin']
  spec.email         = ['kudrin.alexander@gmail.com']

  spec.summary       = 'Domain driven oriented microservice framework.'
  spec.homepage      = 'https://github.com/am-team/luna_park'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 2.5.1'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    # spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end
  spec.metadata['yard.run'] = 'yri'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bugsnag', '~> 6'
  spec.add_development_dependency 'bundler', '~> 2.1'
  spec.add_development_dependency 'byebug', '~> 11.1'
  spec.add_development_dependency 'codecov', '~> 0.2'
  spec.add_development_dependency 'dry-validation', '~> 1.1'
  spec.add_development_dependency 'guard'
  spec.add_development_dependency 'guard-bundler'
  spec.add_development_dependency 'guard-rspec'
  spec.add_development_dependency 'guard-rubocop'
  spec.add_development_dependency 'i18n', '~> 1.8'
  spec.add_development_dependency 'overcommit', '~> 0.55'
  spec.add_development_dependency 'pry', '~> 0.13'
  spec.add_development_dependency 'pry-byebug', '~> 3.9'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rest-client', '~> 2.1'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 0.87'
  spec.add_development_dependency 'sentry-ruby', '~> 4.2'
  spec.add_development_dependency 'simplecov', '~> 0.18'
  spec.add_development_dependency 'timecop', '~> 0.9'
  spec.add_development_dependency 'webmock', '~> 3.7.0'
  spec.add_development_dependency 'yard', '~> 0.9'
end
