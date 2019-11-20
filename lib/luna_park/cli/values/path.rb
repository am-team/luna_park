# frozen_string_literal: true

require 'pathname'
require 'dry/inflector'

module LunaPark
  module CLI
    module Values
      class Path < LunaPark::Values::Single
        EXT = '.rb'

        attr_reader :path

        def dir
          @dir ||= pathname.dirname
        end

        def file_path
          @file_path ||= pathname.sub_ext EXT
        end

        def class_name
          @class_name ||= inflector.classify(pathname.basename)
        end

        def namespaces
          result = []
          dir.each_filename do |space|
            result << inflector.classify(space)
          end
          result
        end

        def self.wrap(value)
          new(value) if value.is_a? String
          super
        end

        private

        def pathname
          @pathname ||= Pathname.new(value)
        end

        def inflector
          @inflector ||= Dry::Inflector.new
        end
      end
    end
  end
end
