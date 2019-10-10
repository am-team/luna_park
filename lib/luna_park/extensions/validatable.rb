# frozen_string_literal: true

module LunaPark
  module Extensions
    # @example
    #   class MyForm
    #     include LunaPark::Extensions::Validatable
    #
    #     validator MyValidator # must respond_to #errors, #success?, #valid_params, .validate
    #
    #     def initialize(params)
    #       @params = params
    #     end
    #
    #     def data
    #       OpenStruct.new(valid_params) if valid?
    #     end
    #
    #     private
    #
    #     attr_reader :params # define abstract method
    #   end
    #
    #   form = MyForm.new(foo: 'Foo')
    #   form.valid?            # => false
    #   form.validation_errors # => { bar: ['is missing'] }
    #   form.data              # => nil
    #
    #   form = MyForm.new(foo: 'Foo', bar: 'Bar')
    #   form.valid?            # => true
    #   form.data              # => #<OpenStruct foo="Foo" bar="Bar" }
    module Validatable
      def self.included(klass)
        klass.include InstanceMethods
        klass.extend  ClassMethods
        super
      end

      module InstanceMethods
        def validation_errors_array
          validation ? validation.errors_array : {}
        end

        def validation_errors_tree
          validation ? validation.errors_tree : []
        end

        def validation_errors
          validation ? validation.errors : {}
        end

        def valid?
          validation ? validation.success? : true
        end

        private

        def valid_params
          validation ? validation.valid_params : params
        end

        def validation
          @validation ||= self.class.validator.validate(params)
        end

        # :nocov:
        def params
          raise Errors::AbstractMethod
        end
        # :nocov:
      end

      module ClassMethods
        def validator(klass = nil)
          klass.nil? ? @validator : @validator = klass
        end
      end
    end
  end
end
