# frozen_string_literal: true

module LunaPark
  module Values
    class Compound
      include Extensions::Attributable

      def initialize(attrs)
        set_attributes attrs
      end

      # :nocov:
      def ==(_other)
        raise Errors::AbstractMethod
      end
      # :nocov:

      class << self
        def wrap(input)
          case input
          when self then input
          when Hash then new(input)
          else raise Errors::Unwrapable, "#{self} can`t wrap #{input.class}"
          end
        end
      end
    end
  end
end
