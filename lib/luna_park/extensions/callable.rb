# frozen_string_literal: true

module LunaPark
  module Extensions
    ##
    # class-level mixin
    #
    # The Callable interface is a generic interface
    # containing a single `call()` method - which returns
    # a generic value
    #
    # @example
    #  class MyCallableObject < LunaPark::Extensions::Callable
    #    def initialize(params)
    #      @params = params
    #    end
    #
    #    def call
    #      # do some stuff with @params
    #      'call used'
    #    end
    #
    #    def call!
    #      # do some stuff with @params
    #      'call! used'
    #    end
    #  end
    #
    #  MyCallableObject.call(params)  # => 'call used'
    #  MyCallableObject.call!(params) # => 'call! used'
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
