# frozen_string_literal: true

module LunaPark
  module Values
    class Simple
      include Extensions::Attributable

      attr_reader :value

      def initialize(value)
        @value = value
      end

      def ==(other)
        value == other.value
      end

      class << self
        def wrap(obj)
          case obj
          when self then obj
          else raise Errors::Unwrapable, "Can`t wrap #{obj.class}"
          end
        end
      end
    end
  end
end
