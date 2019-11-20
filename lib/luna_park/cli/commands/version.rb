# frozen_string_literal: true

module LunaPark
  module CLI
    module Commands
      class Version < Hanami::CLI::Command
        desc 'Print version'

        def call(*)
          puts LunaPark::VERSION
        end
      end

      register 'version', Version, aliases: %w[v -v --version]
    end
  end
end
