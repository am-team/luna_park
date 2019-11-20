# frozen_string_literal: true

module LunaPark
  module CLI
    module Repositories
      module Project
        class Save < LunaPark::UseCases::Command
          def initialize(content, at:)
            self.content = content
            self.path    = at
          end

          private

          attr_reader :content, :path

          def execute
            file = File.open(path.file_path, 'w')
            file.write(content)
          rescue Errno::ENOENT, IOError => e
            raise Errors::CouldNotSaveFile, e.message
          ensure
            file&.close
          end

          def content=(content)
            @content = case content
                       when Entities::Template then content.render
                       else raise LunaPark::Errors::Unwrapable, "Could not wrap #{content.class.name}."
            end
          end

          def path=(path)
            @path = Values::Path.wrap(path)
          end
        end
      end
    end
  end
end
