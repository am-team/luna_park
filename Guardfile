# frozen_string_literal: true

ignore(/
  bin | public | node_modules | tmp | .git
/x)

guard :bundler do
  watch('Gemfile')
  watch('Gemfile.lock')
end

group :specs, halt_on_fail: true do
  guard :rspec,
        cmd: 'bundle exec rspec --color --format documentation',
        all_after_pass: false,
        all_on_start: false,
        failed_mode: :keep do
    require 'guard/rspec/dsl'
    dsl = Guard::RSpec::Dsl.new(self)

    # Feel free to open issues for suggestions and improvements

    # RSpec files
    rspec = dsl.rspec
    watch(rspec.spec_helper) { rspec.spec_dir }
    watch(rspec.spec_support) { rspec.spec_dir }
    watch(rspec.spec_files)

    # Ruby files
    ruby = dsl.ruby
    dsl.watch_spec_files_for(ruby.lib_files)

    watch(%r{^config/(.+)\.rb$})

    watch(%r{^spec/factories/(.+)\.rb$})
  end

  guard :rubocop, all_on_start: false, keep_failed: false do
    watch(/.+\.rb$/)
    watch(%r{(?:.+/)?\.rubocop\.yml$}) { |m| File.dirname(m[0]) }
  end
end
