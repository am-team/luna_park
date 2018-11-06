# frozen_string_literal: true

module LunaPark
  module Extensions
    # The Callable interface is a generic interface
    # containing a single `call()` method - which returns
    # a generic value
    module Callable
      def self.included(klass)
        klass.include InstanceMethods
        klass.extend  ClassMethods
        super
      end

      module InstanceMethods
        # Abstract method should be defined at `callable class`.
        # Should be describe business logic of service.
        # Must return value.
        def call!
          raise NotImplementedError
        end

        ##
        # Safety run `call!` method
        def call
          call!
        rescue Errors::Processing
          nil
        end
      end

      module ClassMethods
        ##
        # Preferred class method to run instance `call` method
        def call(*args)
          new(*args).call
        end

        ##
        # Preferred class method to run instance `call`! method
        def call!(*args)
          new(*args).call!
        end
      end
    end
  end
end
