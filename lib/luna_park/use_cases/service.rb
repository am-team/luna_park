# frozen_string_literal: true

module LunaPark
  module UseCases
    class Service
      extend Extensions::Callable

      def call
        call!
      rescue Errors::Processing
        nil
      end

      def call!
        execute
      end

      private

      def execute
        raise Errors::AbstractMethod
      end
    end
  end
end
