# frozen_string_literal: true

module LunaPark
  module Entities
    # add description
    class Simple
      extend  Extensions::Wrappable
      include Extensions::Attributable

      def initialize(attrs = {})
        set_attributes(attrs)
      end

      def eql?(other)
        other.is_a?(self.class) && self == other
      end

      # @abstract
      def ==(_other)
        raise Errors::AbstractMethod
      end

      def serialize
        to_h
      end

      # @abstract
      def to_h
        raise Errors::AbstractMethod
      end

      public :set_attributes # rubocop:disable Style/AccessModifierDeclarations
    end
  end
end
