# frozen_string_literal: true

require 'luna_park/errors'

begin
  require 'dry-validation'
rescue LoadError => e
  raise unless e.message == 'cannot load such file -- dry-validation'
end

module LunaPark
  module Validators
    class Multiple
      class << self
        alias validate new

        def inherited(child)
          child.__validators__ = __validators__.dup
        end

        def add_validator(validator_class, root: nil)
          __validators__ << [root, validator_class]
        end

        def self.+(other)
          multiple = Class.new(self)
          multiple.add_validator(other)
          multiple
        end

        attr_writer :__validators__

        def __validators__
          @__validators__ ||= []
        end
      end

      def initialize(params)
        @params = params
        @validated = false
      end

      def success?
        succeeded_validations&.any?
      end

      def valid_params
        return {} unless success?

        output = {}
        succeeded_validations.each_with_object({}) do |(root, validator), result|
          build_nested_hash root, output: output

          if root.nil?
            output.merge! validator.valid_params
          else
            *path_keys, head_key = root
            tail = path_keys.any? ? output.dig(*path_keys) : output
            tail[head_key] ||= {}
            tail[head_key].merge! validator.valid_params
          end
        end

        output
      end

      def errors_array
        root, validator = failed_validation

        validator&.errors_array&.map { |item| item.merge({ source: root }.compact) } || []
      end

      def errors_tree(nested_by_validator: false)
        root, validator = failed_validation

        return validator&.errors_tree || {} unless nested_by_validator

        *path_keys, head_key = root

        output = build_nested_hash(path_keys)
        output[head_key] = validator.errors_tree
        output
      end

      private

      attr_reader :params

      def failed_validation
        validate_all
        @failed_validation
      end

      def succeeded_validations
        validate_all
        @succeeded_validations
      end

      def validate_all # rubocop:disable Metrics/MethodLength
        return if @validated

        @validated = true

        succeeded_validations = []

        self.class.__validators__.each do |(root, validator_class)|
          nested_params = root&.any? ? params&.dig(*root) : params

          validation = validator_class.validate(nested_params)

          if validation.success?
            succeeded_validations << [root, validation]
          else
            @failed_validation = [root, validation]

            break
          end
        end

        @succeeded_validations = succeeded_validations if @failed_validation.nil?
      end

      def build_nested_hash(path, output: {})

        path&.reduce(output) { |nested, key| nested[key] ||= {} }

        output
      end
    end
  end
end
