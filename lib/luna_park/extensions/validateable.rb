# frozen_string_literal: true

module LunaPark
  module Extensions
    module Validateable
      def self.included(base)
        base.extend  ClassMethods
        base.include InstanceMethods
      end

      module ClassMethods
        def validator(klass)
          @validator = klass
        end

        def get_validator
          @validator
        end
      end

      module InstanceMethods
        # force revalidate
        def validate!
          @validation = nil
          valid?
        end

        # access validated params
        def valid_params
          (valid? && validation.output) || {}
        end

        def valid?
          validation&.success?
        end

        def validation_errors
          validation&.errors || {}
        end

        private

        def validation
          @validation ||= self.class.get_validator&.validate(raw_params)
        end

        def raw_params
          raise NotImplementedError
        end
      end
    end
  end
end
