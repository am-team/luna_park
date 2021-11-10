# frozen_string_literal: true

require 'luna_park/values/compound'
require 'luna_park/extensions/comparable'
require 'luna_park/extensions/serializable'
require 'luna_park/extensions/dsl/attributes'

module LunaPark
  module Values
    class Attributable < Compound
      include Extensions::Comparable
      include Extensions::Serializable
      extend  Extensions::Dsl::Attributes

      # redefine: make defined setters privat
      def self.attr(*args, **opts)
        super.tap { |result| protected(result[:setter]) }
      end
    end
  end
end
