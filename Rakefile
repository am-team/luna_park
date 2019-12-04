# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RuboCop::RakeTask.new(:rubocop)
RSpec::Core::RakeTask.new(:spec)

task default: [:spec, :rubocop]

namespace :rspec do
  desc 'Run each file separatly for find out where `require` is missed'
  task :separated do
    specfiles = Dir[File.expand_path('../spec/**/*_spec.rb', __FILE__)]
    specfiles.all? { |specfile| system("bundle exec rspec #{specfile}") }
  end
end
