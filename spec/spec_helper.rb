# frozen_string_literal: true

require 'bundler/setup'
require 'pry'

require 'simplecov'

if ENV['CODECOV_TOKEN']
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

SimpleCov.start do
  add_filter(/spec/)

  add_filter do |source_file|
    def line(pattern)
      /^\A\s*#{pattern}/
    end

    def method(pattern)
      /^\A\s*#{pattern}(\(| )/
    end

    source_file.lines.each do |line|
      next unless line.src =~ line(/class/) ||
                  line.src =~ line(/module/) ||
                  line.src =~ line(/[A-Z]+ *=/) || # constant definition
                  line.src =~ line(/def/) ||
                  line.src =~ line(/private($| *#)/) ||
                  line.src =~ method(/require/) ||
                  line.src =~ method(/require_relative/) ||
                  line.src =~ method(/include/) ||
                  line.src =~ method(/extend/) ||
                  line.src =~ method(/attr_reader/) ||
                  line.src =~ method(/attr_writer/) ||
                  line.src =~ method(/attr_accessor/)

      line.skipped!
    end
    false # do not skip file
  end
end

require 'luna_park'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
