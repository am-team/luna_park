# frozen_string_literal: true

module LunaPark
  module Values
    class Single
      include Extensions::Attributable

      attr_reader :value

      def initialize(value)
        @value = value
      end

      def ==(other)
        value == other.value
      end

      def to_s
        value.to_s
      end

      def inspect
        "#<#{self.class} #{value.inspect}>"
      end

      class << self
        def wrap(input)
          return input if input.is_a?(self)

          raise Errors::Unwrapable, "Can`t wrap #{input.class}"
        end
      end
    end
  end
end
