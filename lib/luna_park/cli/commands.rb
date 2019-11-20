# frozen_string_literal: true

require 'hanami/cli'

module LunaPark
  module CLI
    module Commands
      extend Hanami::CLI::Registry

      require 'luna_park/cli/commands/generate'
      require 'luna_park/cli/commands/version'
    end
  end
end
