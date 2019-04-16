require 'thor/group'

module LunaPark
  module CLI
    module Generators
      module Forms
        class Single < Thor::Group
          desc 'generate simple form'

          def generate_file
            puts 'file'
          end

          def generate_spec
            puts 'spec'
          end
        end
      end
    end
  end
end