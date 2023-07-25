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
        def validator(klass = nil)
          klass.nil? ? @validator : @validator = klass
        end

        # validators do
        #   validator :headers, HeadersValidator
        #   validator :uri, :path, Validators::Uid + Validators::UserUid
        #   validator :uri, :query do
        #     required(:from).filled(:string)
        #     required(:to).filled(:string)
        #   end
        #   validator :body, BodyValidator
        # end
        def validators(&block)
          require 'luna_park/validators/multiple'

          raise "Not Multiple validator is already defined: #{validator}" unless validator.nil? || validator < LunaPark::Validators::Multiple

          validator(validator || Class.new(LunaPark::Validators::Multiple))
          MultipleValidatorsBuilder.new(validator).instance_eval(&block)
        end

        def inherited(child)
          child.validator Class.new(validator) if validator
          super
        end
      end

      class MultipleValidatorsBuilder
        def initialize(multi_validator)
          @multi_validator = multi_validator
        end

        def validator(*args)
          *path, object = args
          @multi_validator.add_validator object, root: path
        end

        def dry_validator(*args, &block)
          validator_class = Class.new(Validators::Dry)
          validator_class.validation_schema(&block)
          @multi_validator.add_validator validator_class, root: args
        end
      end
    end
  end
end
