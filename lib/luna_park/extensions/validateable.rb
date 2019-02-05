# frozen_string_literal: true

require 'forwardable'

module LunaPark
  module Extensions
    ##
    # The Runnable interface is a generic interface
    # containing a single `run()` method - which returns
    # a true
    #
    # @example
    #  class MyForm
    #    include LunaPark::Extensions::Validateable
    #
    #    attr_reader :params # implement abstract method #params
    #
    #    validator MyLunaParkValidator
    #
    #    def initialize(params)
    #      @params = params
    #    end
    #
    #    def complete
    #      if valid?
    #        do_valid_stuff(validation)
    #      end
    #    end
    #
    #    def errors
    #      do_invalid_stuff(validation)
    #    end
    #  end
    #
    #  form = MyForm.new(params).complete
    module Validateable
      def self.included(klass)
        klass.include InstanceMethods
        klass.extend  ClassMethods
        super
      end

      module InstanceMethods
        extend Forwardable

        private

        ##
        # validation result object
        def validation
          @validation ||= self.class.validate(params)
        end

        # :nocov:

        ##
        # Abstract method for params that will be validated
        #
        # @abstract
        def params
          raise Errors::AbstractMethod
        end
        # :nocov:

        delegate %i[valid? validation_errors valid_params] => :validation
      end

      module ClassMethods
        def validator(klass)
          @_validator = klass
        end

        # @api private
        def validate(params)
          @_validator&.validate(params)
        end
      end
    end
  end
end
