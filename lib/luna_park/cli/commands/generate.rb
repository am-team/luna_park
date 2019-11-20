# frozen_string_literal: true

module LunaPark
  module CLI
    module Commands
      module Generate
        require 'luna_park/cli/commands/generate/form_simple'
        require 'luna_park/cli/commands/generate/form_single'
      end

      register 'generate', aliases: ['g'] do |prefix|
        # prefix.register 'form:simple', Generate::FormSimple
        prefix.register 'form:single', Generate::FormSingle
      end
    end
  end
end
