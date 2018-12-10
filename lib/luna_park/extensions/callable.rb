# frozen_string_literal: true

module LunaPark
  module Extensions
    # The Callable interface is a generic interface
    # containing a single `call()` method - which returns
    # a generic value
    module Callable
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
