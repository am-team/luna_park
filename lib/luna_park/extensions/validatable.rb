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

        def validation_errors_tree(**opts)
          validation ? validation.errors_tree(**opts) : []
        end

        def validation_errors
          validation ? validation.errors_tree : {}
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
        def validator(*args)
          return @validator if args.empty?

          raise ArgumentError, 'last argument must be a validator' if args.last.is_a? Symbol

          *path, new_validator = args
          return @validator = new_validator if @validator.nil? && path.empty?

          require 'luna_park/validators/multiple'

          nested_validator(path, new_validator)
        end

        private

        def inherited(child)
          child.validator Class.new(validator) if validator
          super
        end

        def nested_validator(path, new_validator)
          if @validator.nil?
            @validator = Class.new(LunaPark::Validators::Multiple)
          elsif !(@validator < LunaPark::Validators::Multiple)
            multiple = Class.new(LunaPark::Validators::Multiple)
            multiple.add_validator @validator
            @validator = multiple
          end

          @validator.add_validator new_validator, path: path
          @validator
        end
      end
    end
  end
end
