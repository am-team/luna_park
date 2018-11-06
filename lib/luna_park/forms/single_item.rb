# frozen_string_literal: true

module LunaPark
  module Forms
    class SingleItem
      include Extensions::Attributable
      include Extensions::Validateable

      attr_reader :result

      def initialize(params = {})
        @params = params
      end

      def complete!
        if validate!
          fill!
          perform!
          true
        else false
        end
      end

      alias_method :errors, :validation_errors

      private

      attr_reader :params

      def fill!
        # For JSONApi rewrite .dig(:data, :attributes)
        set_attributes valid_params
      end

      def perform!
        @result = perform
      end

      def perform
        raise NotImplementedError
      end
    end
  end
end
