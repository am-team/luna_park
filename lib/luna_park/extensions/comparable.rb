# frozen_string_literal: true

module LunaPark
  module Extensions
    # @example
    #   class Money
    #     include LunaPark::Extensions::Comparable
    #
    #     attr_reader :amount, :currency, :meta
    #
    #     comparable_attributes :amount, :currency
    #
    #     def initialize(amount, currency, meta = nil)
    #       @amount = amount
    #       @currency = currency
    #       @meta = meta
    #     end
    #   end
    #
    #   Money.new(1, 'USD')         == Money.new(2, 'USD')         # => false
    #   Money.new(1, 'USD')         == Money.new(1, 'USD')         # => true
    #   Money.new(1, 'USD', 'meta') == Money.new(1, 'USD', 'feta') # => true
    module Comparable
      def self.included(base)
        base.extend  ClassMethods
        base.include InstanceMethods
      end

      module ClassMethods
        ##
        # Enable debug mode (just include debug methods)
        def enable_debug
          include ComparableDebug unless include?(ComparableDebug)
          self
        end

        alias debug enable_debug

        ##
        # Describe methods list that will be used for comparsion via `#==` method
        def comparable_attributes(*names)
          raise 'No attributes given' if names.compact.empty?

          @comparable_attributes_list ||= []
          @comparable_attributes_list.concat(names).compact!
        end

        ##
        # List of methods that will be used for comparsion via `#==` method
        def comparable_attributes_list
          return @comparable_attributes_list if @comparable_attributes_list

          raise Errors::NotConfigured,
                "You must set at least one comparable attribute using #{self}.comparable_attributes(*names)"
        end

        private

        def inherited(child)
          super
          child.instance_variable_set(:@comparable_attributes_list, @comparable_attributes_list&.dup)
        end
      end

      module InstanceMethods
        ##
        # Compare this object with other using methids, described with `::comparable_attributes` method
        def eql?(other)
          return false unless other.is_a?(self.class)

          self.class.comparable_attributes_list.all? { |attr| send(attr) == other.send(attr) }
        end

        alias == eql?

        ##
        # Enable debug mode (just include debug methods)
        def enable_debug
          self.class.enable_debug
          self
        end

        alias debug enable_debug
      end
    end
  end
end
