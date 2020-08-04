# frozen_string_literal: true

module LunaPark
  module Tools
    class Environment < String
      def initialize(environment, allowed:)
        super(environment.to_s)

        guard_allowed(environment, allowed)

        allowed.each { |env| define_singleton_method(:"#{env}?") { self == env } }
      end

      def env?(*envorinments)
        envorinments.any? { |env| public_send(:"#{env}?") }
      end

      def inspect
        "#<#{self.class} #{self}>"
      end

      def ==(other)
        to_s == other.to_s
      end

      private

      def guard_allowed(environment, allowed)
        return if allowed.any? { |env| self == env }

        raise "Not allowed environment: #{environment}. Allowed: #{allowed.join(', ')}"
      end
    end
  end
end
