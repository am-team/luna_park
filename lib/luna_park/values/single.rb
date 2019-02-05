# frozen_string_literal: true

module LunaPark
  module Values
    class Single
      include Extensions::Attributable

      def self.wrap(input)
        return input if input.is_a?(self)

        raise Errors::Unwrapable, "#{self} can not wrap #{input.class}"
      end

      def initialize(value)
        @value = value
      end

      def ==(other)
        value == other.value
      end

      def to_s
        value.to_s
      end

      def serialize
        value
      end

      def inspect
        "#<#{self.class} #{value.inspect}>"
      end

      protected

      attr_reader :value
    end
  end
end
