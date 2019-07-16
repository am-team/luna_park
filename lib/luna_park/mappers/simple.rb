# frozen_string_literal: true

require_relative '../errors'

module LunaPark
  module Mappers
    # Abstract mapper for transform data from Entity attributes schema to Database row schema
    # @example
    #   class TransactionMapper < LunaPark::Mappers::Simple
    #     def self.from_row(row)
    #       {
    #         uid: row[:id],
    #         charge: {
    #           amount:   row[:charge_amount],
    #           currency: row[:charge_currency]
    #         },
    #         comment: row[:comment]
    #       }
    #     end
    #
    #     def self.to_row(attributes)
    #       {
    #         id:              attributes[:uid],
    #         charge_amount:   attributes.dig(:charge, :amount),
    #         charge_currency: attributes.dig(:charge, :currency),
    #         comment:         attributes[:comment]
    #       }
    #     end
    #   end
    #
    # @example
    #   # attribute scheme repeats entity schema
    #   attributes = { charge: { amount: 10, currency: 'USD' }, comment: 'FooBar' }
    #
    #   # Mapper transforms entity attributes to database row
    #   row = TransactionMapper.to_row(attributes)
    #
    #   # Mapper also transforms database row to entity attributes
    #   attributes = TransactionMapper.from_row(row)
    #
    # @example
    #   # find
    #   row = sequel_database_table.where(id: 42).first
    #   attributes = TransactionMapper.from_row(row)
    #   Entities::Transaction.new(attributes)
    #
    # @example
    #   # update
    #   new_attributes = { charge: { amount: 10, currency: 'USD' }, comment: 'FooBar' }
    #   new_row = TransactionMapper.to_row(new_attributes)
    #   sequel_database_table.update(42, new_row)
    #
    # @example
    #   # create
    #   attributes = { charge: { amount: 10, currency: 'USD' }, comment: 'FooBar' }
    #   transaction = Entities::Transaction.new(attributes)
    #
    #   row            = TransactionMapper.to_row(transaction.to_h)  # => { charge_amount: 10, ... }
    #   new_row        = sequel_database_table.returning.insert(row) # => { id: 123, charge_amount: 10, ... }
    #   new_attributes = TransactionMapper.from_row(new_row)         # => { uid: 123, charge: { amount: 10, ... }
    #   transaction.set_attributes(new_attributes)
    class Simple
      class << self
        ##
        # Transforms array of rows to array of attribute hashes
        def from_rows(rows)
          return [] if rows.nil?

          rows.to_a.map { |hash| from_row(hash) }
        end

        ##
        # Transforms array of attribute hashes to array of rows
        def to_rows(attr_hashes)
          return [] if attr_hashes.nil?

          attr_hashes.to_a.map { |entity| to_row(entity) }
        end

        # @abstract
        def from_row(_row)
          raise Errors::AbstractMethod
        end

        # @abstract
        def to_row(_attrs)
          raise Errors::AbstractMethod
        end
      end
    end
  end
end
