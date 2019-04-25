# frozen_string_literal: true

module LunaPark
  module Extensions
    # @example
    #   Foo = Struct.new(:uid, :name) do
    #     include LunaPark::Extensions::PrimaryKey
    #
    #     primary_key_attribute(:uid)
    #   end
    #
    #   Foo.pk_attribute_name # => :uid
    #
    #   foo = Foo.new(42, 'FOO')
    #   foo.uid         # => 42
    #   foo.primary_key # => 42
    #   foo.pk          # => 42
    #
    #   Foo.wrap_pk(foo) # => 42
    #   Foo.wrap_pk(42)  # => 42
    module PrimaryKey
      def self.included(base)
        base.extend  ClassMethods
        base.include InstanceMethods
      end

      module ClassMethods
        def primary_key_attribute(name)
          raise 'Not Symbol or String given' unless name.is_a?(Symbol) || name.is_a?(String)

          @primary_key_attribute_name = name
        end

        def primary_key_attribute_name
          return @primary_key_attribute_name if @primary_key_attribute_name

          raise Errors::NotConfigured,
                "You must set primary_key attribute using #{self}.primary_key_attribute(name)"
        end

        alias pk_attribute_name primary_key_attribute_name

        def wrap_primary_key(input)
          case input
          when self            then input.primary_key
          when Integer, String then input
          else raise Errors::Unwrapable, "#{self} can not wrap_primary_key #{input.class}"
          end
        end

        alias wrap_pk wrap_primary_key

        private

        def inherited(child)
          super
          child.instance_variable_set(:@primary_key_attribute_name, @primary_key_attribute_name&.dup)
        end
      end

      module InstanceMethods
        def primary_key
          send self.class.primary_key_attribute_name
        end

        alias pk primary_key
      end
    end
  end
end
