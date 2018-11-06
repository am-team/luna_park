module LunaPark
  module Extensions
    # The Runnable interface is a generic interface
    # containing a single `run()` method - which returns
    # a true
    module Runnable
      def self.included(klass)
        klass.include InstanceMethods
        klass.extend  ClassMethods
        super
      end

      module InstanceMethods

        # Unsafety runner, should raise `Errors::Processing`
        # of fail
        #
        # @return true
        def run!
          call!
          true
        end

        ##
        # Safety runner
        #
        # @return [true, false]
        def run
          run!
        rescue Errors::Processing
          false
        end

        private

        # Abstract method should be defined at `runnable class`.
        # You dont need think about what it return
        def call!
          raise NotImplementedError
        end
      end

      module ClassMethods
        ##
        # Preferred class method to run instance `run` method
        #
        # @return [true]
        def run(*args)
          new(*args).run
        end

        ##
        # Preferred class method to run instance `run!` method
        #
        # @return [true, false]
        def run!(*args)
          new(*args).run!
        end
      end
    end
  end
end
