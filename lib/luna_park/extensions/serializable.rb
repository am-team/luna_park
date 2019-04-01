# frozen_string_literal: true

module LunaPark
  module Extensions
    # @example
    #   class Money
    #     include LunaPark::Extensions::Comparable
    #
    #     attr_accessor :amount, :currency, :meta
    #
    #     serializable_attributes :amount, :currency
    #   end
    #
    #   money = Money.new
    #   money.to_h             # => {}
    #   money.amount = 1
    #   money.to_h             # => { amount: 1 }
    #   money.currency = 'USD'
    #   money.meta     = 'meta'
    #   money.to_h             # => { amount: 1, currency: 'USD' }
    module Serializable
      def self.included(base)
        base.extend  ClassMethods
        base.include InstanceMethods
      end

      module ClassMethods
        ##
        # Describe methods list that will be used for serialization via `#to_h` and `#serialize` methods
        def serializable_attributes(*names)
          raise 'No attributes given' if names.compact.empty?

          @serializable_attributes_list ||= []
          @serializable_attributes_list.concat(names).compact!
        end

        ##
        # List of methods that will be used for serialization via `#to_h` and `#serialize` methods
        def serializable_attributes_list
          return @serializable_attributes_list if @serializable_attributes_list

          raise Errors::NotConfigured,
                "You must set at least one serializable attribute using #{self}.serializable_attributes(*names)"
        end

        private

        def inherited(child)
          super
          child.instance_variable_set(:@serializable_attributes_list, @serializable_attributes_list&.dup)
        end
      end

      module InstanceMethods
        ##
        # Serialize object using methods, described with `::comparable_attributes` method
        def serialize
          self.class
              .serializable_attributes_list
              .each_with_object({}) do |field, output|
            next unless instance_variable_defined?(:"@#{field}")

            output[field] = serialize_value__(send(field))
          end
        end

        ##
        # For powerfull polymorphism with Hashes
        alias to_h serialize

        def inspect
          attrs = self.class.serializable_attributes_list.map do |attr|
            value = instance_variable_get(:"@#{attr}")
            "#{attr}=#{value.inspect}" if value
          end
          "#<#{self.class.name} #{attrs.compact.join(' ')}>"
        end

        private

        SERIALIZABLE = ->(o) { o.respond_to?(:serialize) }.freeze
        HASHABLE     = ->(o) { o.respond_to?(:to_h) }.freeze

        def serialize_value__(value)
          case value
          when Array then value.map              { |v| serialize_value__(v) } # TODO: work with Array (wrap values)
          when Hash  then value.transform_values { |v| serialize_value__(v) }
          when nil   then nil
          when SERIALIZABLE then value.serialize
          when HASHABLE     then value.to_h
          else value
          end
        end
      end
    end
  end
end
