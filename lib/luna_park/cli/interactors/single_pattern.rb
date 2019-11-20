# frozen_string_literal: true

require 'pathname'

# Developer.call pattern: :form, type: :single, at: path, opts: opts
module LunaPark
  module CLI
    module Interactors
      class SinglePattern < LunaPark::Interactors::Sequence
        private

        def execute
          tpl = Entities::Template.new(
            pattern: pattern,
            type: type,
            class_name: path.class_name,
            namespaces: path.namespaces,
            opts: opts
          )

          Repositories::Project.mkdir path, with: opts
          Repositories::Project.save  tpl,  at:   path
        end

        def returned_data
          true
        end

        attr_accessor :pattern, :type, :at, :opts

        def path
          @path ||= Values::Path.wrap(at)
        end
      end
    end
  end
end
