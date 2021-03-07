# frozen_string_literal: true

module LunaPark
  module Extensions
    module Dsl
      # @example
      #  class TransactionA
      #    include LunaPark::Extensions::Dsl::PrimaryKey
      #  end
      #
      #  class TransactionB < TransactionA
      #    pk :uid
      #  end
      #
      #  ta = TransactionA.new(id)
      #  ta = TransactionA.new
      module PrimaryKey
        DEFAULT_PRIMARY_KEY = :id

        def self.extended(base)
          base.extend  ClassMethods
          base.include InstanceMethods
        end

        module ClassMethods
          def primary_key(pk = nil)
            return @primary_key || DEFAULT_PRIMARY_KEY if pk.nil?

            attr_accessor pk
            serializable_attributes(pk) if include?(Serializable)
            comparable_attributes(pk)   if include?(Comparable)

            @primary_key = pk
          end

          alias pk primary_key

          def wrap_primary_key(input)
            case input
            when self then input.primary_key
            when Hash then input[primary_key]
            else           input
            end
          end

          alias wrap_pk wrap_primary_key

          private

          def inherited(child_class)
            super
            child_class.primary_key primary_key if primary_key
          end
        end

        module InstanceMethods
          def primary_key
            public_send(self.class.primary_key)
          end

          alias pk primary_key
        end
      end
    end
  end
end
