# frozen_string_literal: true

module LunaPark
  module UseCases
    class Command
      extend Extensions::Callable

      def call
        call!
      rescue Errors::Processing
        false
      end

      def call!
        execute
        true
      end

      private

      def execute
        raise Errors::AbstractMethod
      end
    end
  end
end
