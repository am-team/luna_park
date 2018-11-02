# frozen_string_literal: true

require 'dry-validation'

module LunaPark
  # add description
  class Validator
    def validate(params)
      self.class.validate(params)
    end

    class << self
      def validate(params)
        @validation_schema.call(params)
      end

      private

      def schema(&block)
        @validation_schema = Dry::Validation.Schema(&block)
      end
    end
  end
end
