# frozen_string_literal: true

module LunaPark
  module Values
    class Compound
      include Extensions::Attributable

      def initialize(attrs)
        set_attributes attrs
      end

      def ==(_other)
        raise Errors::AbstractMethod
      end

      class << self
        def wrap(obj)
          case obj
          when self then obj
          else raise Errors::Unwrapable "Can`t wrap #{obj.class}"
          end
        end
      end
    end
  end
end
