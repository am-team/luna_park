# frozen_string_literal: true

module LunaPark
  module Values
    class Compound
      extend  Extensions::Wrappable
      include Extensions::Attributable

      def initialize(attrs)
        set_attributes attrs
      end

      # :nocov:

      # @abstract
      def ==(_other)
        raise Errors::AbstractMethod
      end
      # :nocov:
    end
  end
end
