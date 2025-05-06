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

        def add_validator(validator_class, path: nil)
          __validators__ << [path || [], validator_class]
        end

        def +(other)
          new_multi_validator = Class.new(self)

          if other.is_a?(Class) && other < Multiple
            new_multi_validator.__validators__.concat other.__validators__
          else
            new_multi_validator.add_validator(other)
          end

          new_multi_validator
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
        succeeded_validations.each do |(path, validation)|
          build_nested_hash(path, output: output)
            .merge!(validation.valid_params)
        end
        output
      end

      def errors_array
        return [] if failed_validation.nil?

        path, validation = failed_validation
        validation.errors_array.map { |item| item.merge(source: path) } || []
      end

      def error_arrays
        return [] if failed_validation.nil?

        path, validation = failed_validation
        *tail_keys, head_key = path

        output = {}
        validation.errors_array.each do |item|
          tail = build_nested_hash(tail_keys, output: output)
          tail[head_key] ||= []
          tail[head_key] << item.merge(source: path)
        end
        output
      end

      def errors_tree
        return {} if failed_validation.nil?

        path, validation = failed_validation
        return validation.errors_tree || {} if path.empty?

        *tail_keys, head_key = path

        output = {}
        tail = build_nested_hash(tail_keys, output: output)
        tail[head_key] = validation.errors_tree
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

        succeeded_validations = []

        self.class.__validators__.each do |(path, validator_class)|
          nested_params = path.any? ? params.dig(*path) : params
          validation = validator_class.validate(nested_params)

          if validation.success?
            succeeded_validations << [path, validation]
          else
            @failed_validation = [path, validation]

            break
          end
        end

        @validated = true
        @succeeded_validations = succeeded_validations if @failed_validation.nil?
      end

      def build_nested_hash(path, output:)
        path.reduce(output) { |nested, key| nested[key] ||= {} }
      end
    end
  end
end
