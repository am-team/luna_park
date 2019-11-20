# frozen_string_literal: true

require 'pathname'
require 'dry/inflector'

module LunaPark
  module CLI
    module Entities
      class Template < LunaPark::Entities::Simple
        DIR = 'cli/templates/patterns'
        EXT = '.rb.erb'

        attr_reader   :pattern, :type
        attr_accessor :opts, :class_name, :namespaces

        def pattern=(attr)
          @pattern = String(attr)
        end

        def type=(attr)
          @type = String(attr)
        end

        def file_path
          # luna_park/lib/luna_park/cli/templates/patterns/type.rb.rb
          (Gem.lib + Gem.title + DIR + pattern_dir + type).sub_ext EXT
        end

        def file
          File.read(file_path)
        end

        def render
          result = ''
          size = namespaces.size - 1

          # module App
          #   module Subdomain
          #     module Pattern
          (0..size).to_a.each do |idx|
            spaces = ' ' * idx * 2
            result << [spaces, 'module', ' ', namespaces[idx], "\n"].join
          end

          #     class ClassName
          #     end
          filled_tpl.each_line do |line|
            spaces = ' ' * (size + 1) * 2
            result << [spaces, line].join
          end

          #     end
          #   end
          # end
          (0..size).to_a.reverse_each do |idx|
            spaces = ' ' * idx * 2
            result << [spaces, 'end', "\n"].join
          end

          result
        end

        private

        def pattern_dir
          Dry::Inflector.new.pluralize(pattern)
        end

        def erb
          ERB.new(file)
        end

        def filled_tpl
          @filled_tpl ||= erb.result_with_hash(class_name: class_name, opts: opts)
        end
      end
    end
  end
end
