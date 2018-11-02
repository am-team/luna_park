module LunaPark
  module Extensions
    ##
    # The Callable interface is a generic interface
    # containing a single `call()` method - which returns
    # a generic value
    module Callable
      ##
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

      def self.included(base)
        base.extend(ClassMethods)
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