# frozen_string_literal: true

module LunaPark
  module CLI
    module Repositories
      module Project
        class Mkdir < LunaPark::UseCases::Command
          Options = Struct.new(:create_dir)

          def initialize(path, opts = {})
            self.path    = path
            self.options = opts
          end

          private

          attr_reader :path, :options

          def execute
            return true if Dir.exist?(path.dir)

            return true if options.create_dir && FileUtils.mkdir_p(path.dir)

            raise Errors::CouldNotCreateDir, "Could not create dir '#{path.dir}' you should do it manual"
          end

          def options=(opts)
            @options = Options.new(
              opts.fetch(:create_dir, false)
            )
          end

          def path=(path)
            @path = Values::Path.wrap(path)
          end
        end
      end
    end
  end
end
