# frozen_string_literal: true

module LunaPark
  module Extensions
    ##
    # allows to use Dependency Injection with DI Container
    #   works as .attr_accessor, but with default value and private getter
    #   By the way: you don't needed DI ewerywhere cause this is Ruby, and you have RSpec with his #allow etc.
    #
    # @example
    #   class CreateTransaction
    #     include LunaPark::Extensions::DependencyInjectable
    #
    #     dependency(:repository) { Repository.new }
    #     dependency :today,      -> { Date.today }
    #     dependency :notifier,   Notifier, call: false
    #
    #     def call
    #       [repository, today, notifier]
    #     end
    #   end
    #
    #   service = CreateTransaction.new(attrs)
    #   service.repository              # => raised "private method called"
    #   service.send(:repository)       # => #<Repository ...>
    #   service.dependencies.repository # => #<Repository ...>
    #   service.call                    # => [#<Repository ...>, #<Date ...>, Notifier]
    #
    #   service.dependencies = OpenStruct.new(repository: 'REPO', today: 'TODAY')
    #   service.call # => ["REPO", "TODAY", nil]
    module DependencyInjectable
      def self.included(base)
        base.extend  ClassMethods
        base.include InstanceMethods
      end

      # DI Container Mixin
      module SimpleContainer
        def register(name, value = nil, call: true, &block)
          if block_given?
            call ? define_method(name, &block) : define_method(name) { block }
          elsif value
            call ? define_method(name, &value) : define_method(name) { value }
          else
            raise ArgumentError, 'Expected value or block'
          end
        end
      end

      module ClassMethods
        def dependency(name, value = nil, call: true, &block)
          dependencies.register(name, value, call: call, &block)
          private(define_method(name) { dependencies.public_send(name) })
        end

        def dependencies
          @dependencies ||= Class.new { extend SimpleContainer }
        end
      end

      module InstanceMethods
        attr_writer :dependencies

        def dependencies
          @dependencies ||= self.class.dependencies.new
        end
      end
    end
  end
end
