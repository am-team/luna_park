# frozen_string_literal: true

module LunaPark
  module Values
    class Attributable < Compound
      include Extensions::Comparable
      include Extensions::Serializable
      include Extensions::Dsl::Attributes

      # redefine: make defined setters privat
      def self.attr(*args, **opts)
        super.tap do |result|
          private(result[:setter]) # rubocop:disable Style/AccessModifierDeclarations
        end
      end
    end
  end
end
