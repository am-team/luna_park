# frozen_string_literal: true

require_relative '../extensions/attributable'

module LunaPark
  module Forms
    class SingleItem
      include Extensions::Attributable

      attr_reader :result

      def initialize(params = {})
        @params = params
      end

      def complete!
        if validate! && valid?
          fill!
          @result = perform!
        else false
        end
      end

      def errors
        validation_result&.errors || {}
      end

      private

      attr_reader :params

      def validation_result
        @validation_result ||= self.class.validate(params)
      end

      def valid?
        validation_result.success?
      end

      def validate!
        @validation_result = nil
        validation_result
      end

      def valid_params
        (valid? && validation_result.output) || {}
      end

      def fill!
        set_attributes(valid_params.dig(:data, :attributes))
      end

      def perform!
        raise NotImplementedError
      end

      class << self
        def validator(klass)
          @_validator = klass
        end

        def validate(params)
          @_validator.validate(params) if validator?
        end

        def validator?
          @_validator
        end
      end
    end
  end
end
