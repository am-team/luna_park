# frozen_string_literal: true

require_relative 'compound'
require_relative '../extensions/comparable'
require_relative '../extensions/serializable'
require_relative '../extensions/dsl/attributes'

module LunaPark
  module Values
    class Attributable < Compound
      include Extensions::Comparable
      include Extensions::Serializable
      extend  Extensions::Dsl::Attributes

      # redefine: make defined setters privat
      def self.attr(*args, **opts)
        super.tap { |result| protected(result[:setter]) } # rubocop:disable Style/AccessModifierDeclarations
      end
    end
  end
end
