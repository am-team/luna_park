# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'irb'
require 'irb/completion'

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

desc 'IRB console with required LunaPark (alias c)'
task :console do
  require 'luna_park'
  require 'irb'
  ARGV.clear
  IRB.start
end

task :c, [] => :console
