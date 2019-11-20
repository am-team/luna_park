# frozen_string_literal: true

module LunaPark
  module CLI
    module Repositories
      module Project
        require 'luna_park/cli/repositories/project/mkdir'
        require 'luna_park/cli/repositories/project/save'

        class << self
          def mkdir(path, with:)
            Mkdir.call!(path, with)
          end

          def save(template, at:)
            Save.call!(template, at: at)
          end
        end
      end
    end
  end
end
