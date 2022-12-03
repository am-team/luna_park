# frozen_string_literal: true

require 'luna_park/errors'

begin
  require 'dry-validation'
rescue LoadError => e
  raise unless e.message == 'cannot load such file -- dry-validation'
end

module LunaPark
  module Validators
    class Dry
      def initialize(params)
        @params = params
      end

      def success?
        result.success?
      end

      def valid_params
        (success? && result.to_h) || {}
      end

      def errors_array
        result.errors.map { |error| { path: error.path, text: error.text, input: error.input } }
      end

      def errors_tree
        result.errors.to_h || {}
      end

      alias errors errors_tree

      private

      attr_reader :params

      def result
        @result ||= self.class.schema.call(params)
      end

      class << self
        def schema
          @_schema
        end

        alias validate new

        def validation_schema(&)
          unless defined?(::Dry::Validation)
            raise NameError, "uninitialized constant ::Dry::Validation\n" \
                             'Perhaps you forgot to add gem "dry-validation"'
          end

          unless defined?(::Dry::Validation::Contract)
            raise NameError, "uninitialized constant ::Dry::Validation::Contract\n" \
                             'which appears in version 1.0 of gem "dry-validation"'
          end

          @_schema = Class.new(::Dry::Validation::Contract, &).new
        end
      end
    end
  end
end
