# frozen_string_literal: true

require 'rubygems/specification'
require 'pathname'

module LunaPark
  class Gem
    TITLE = 'luna_park'

    class << self
      def spec
        ::Gem::Specification.find_by_name(title)
      end

      def root
        Pathname.new spec.gem_dir
      end

      def lib
        root + 'lib'
      end

      def title
        TITLE
      end

      def version
        VERSION
      end
    end
  end
end
