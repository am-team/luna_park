# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RuboCop::RakeTask.new(:rubocop)
RSpec::Core::RakeTask.new(:spec)

task default: [:spec, :rubocop]

namespace :test do
  desc 'Refresh all VCR cassette fixtures and run VCR specs to create new'
  task :separated do
    specfiles = Dir[File.expand_path('../spec/**/*_spec.rb', __FILE__)]
    count = 0
    specfiles.reduce do |result, specfile|
      count += 1
      result && system("bundle exec rspec #{specfile}")
    end

    puts "Finished #{count} from #{specfiles.size} spec files"
  end
end
