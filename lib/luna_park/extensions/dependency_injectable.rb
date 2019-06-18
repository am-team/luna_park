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
    #     dependency :observer                        # dependency without default value
    #     dependency(:repository) { Repository.new }  # callable dependency as block (will be called every time) as block
    #     dependency :time, -> { Time.now }           # callable dependency as callable object (will be called every time)
    #     dependency :notifier, Notifier, call: false # dependency with default static object
    #
    #     def call
    #       [repository, time, notifier]
    #     end
    #   end
    #
    #   service = CreateTransaction.new(attrs)
    #   service.repository              # => raise "private method called"
    #   service.send(:repository)       # => #<Repository ...>
    #   service.dependencies.repository # => #<Repository ...>
    #   service.call                    # => [#<Repository ...>, #<Date ...>, Notifier]
    #
    #   service.dependencies.time = 'NOW'
    #   service.call # => ["REPO", "NOW", nil]
    #
    #   service.dependencies = OpenStruct.new(repository: 'REPO', time: 'YESTERDAY')
    #   service.call # => ["REPO", "YESTERDAY", nil]
    module DependencyInjectable
      def self.included(base)
        base.extend  ClassMethods
        base.include InstanceMethods
      end

      # DI Container
      class SimpleContainer
        # @example
        # class MyContainer < SimpleContainer
        #   dependency(:foo)   { 'Foo' }
        #   dependency :bar, ->{ 'Bar' }
        #   dependency :baz,     'Baz', call: false
        #   dependency :bat
        # end
        #
        # container = MyContainer.new
        # container.foo #= > "Foo"
        # container.bar #= > "Bar"
        # container.baz #= > "Baz"
        # container.bat #= >  nil
        # container.bat = 'Bat'
        # container.bat #= > "Bat"
        def self.dependency(getter, value = nil, call: true, &block) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
          ivar   = :"@#{getter}"
          setter = :"#{getter}="

          if block_given?
            define_method(getter) { block.call || instance_variable_get(ivar) }
            define_method(setter) { |input| instance_variable_set(ivar, input) }
          elsif value && call
            define_method(getter) { value.call || instance_variable_get(ivar) }
            define_method(setter) { |input| instance_variable_set(ivar, input) }
          elsif value
            define_method(getter) { value || instance_variable_get(ivar) }
            define_method(setter) { |input| instance_variable_set(ivar, input) }
          end
        end
      end

      module ClassMethods
        def dependency(name, value = nil, call: true, &block)
          dependencies.dependency(name, value, call: call, &block)
          private(define_method(name) { dependencies.public_send(name) })
        end

        def dependencies
          @dependencies ||= Class.new(SimpleContainer)
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
