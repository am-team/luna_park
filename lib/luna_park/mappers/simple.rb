# frozen_string_literal: true

require 'luna_park/mappers/errors'

module LunaPark
  module Mappers
    ##
    # Abstract mapper for transform data from Entity attributes schema to Database record schema
    #
    # @example
    #   class TransactionMapper < LunaPark::Mappers::Simple
    #     def self.from_record(record)
    #       {
    #         uid: record[:id],
    #         charge: {
    #           amount:   record[:charge_amount],
    #           currency: record[:charge_currency]
    #         },
    #         comment: record[:comment]
    #       }
    #     end
    #
    #     def self.to_record(attributes)
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
    #   # Mapper transforms entity attributes to database record
    #   record = TransactionMapper.to_record(attributes)
    #
    #   # Mapper also transforms database record to entity attributes
    #   attributes = TransactionMapper.from_record(record)
    #
    # @example
    #   # find
    #   record = sequel_database_table.where(id: 42).first
    #   attributes = TransactionMapper.from_record(record)
    #   Entities::Transaction.new(attributes)
    #
    # @example
    #   # update
    #   new_attributes = { charge: { amount: 10, currency: 'USD' }, comment: 'FooBar' }
    #   new_record = TransactionMapper.to_record(new_attributes)
    #   sequel_database_table.update(42, new_record)
    #
    # @example
    #   # create
    #   attributes = { charge: { amount: 10, currency: 'USD' }, comment: 'FooBar' }
    #   transaction = Entities::Transaction.new(attributes)
    #
    #   record            = TransactionMapper.to_record(transaction.to_h)  # => { charge_amount: 10, ... }
    #   new_record        = sequel_database_table.returning.insert(record) # => { id: 123, charge_amount: 10, ... }
    #   new_attributes = TransactionMapper.from_record(new_record)         # => { uid: 123, charge: { amount: 10, ... }
    #   transaction.set_attributes(new_attributes)
    class Simple
      class << self
        ##
        # Transforms array of records to array of attribute hashes
        def from_records(records)
          return [] if records.nil?
          raise Errors::NotArray.new(input: records) unless records.is_a?(Array)

          records.to_a.map { |hash| from_record(hash) }
        end

        ##
        # Transforms array of attribute hashes to array of records
        def to_records(attr_hashes)
          return [] if attr_hashes.nil?
          raise Errors::NotArray.new(input: attr_hashes) unless attr_hashes.is_a?(Array)

          attr_hashes.to_a.map { |entity| to_record(entity) }
        end

        # @abstract
        def from_record(_record)
          raise LunaPark::Errors::AbstractMethod
        end

        # @abstract
        def to_record(_attrs)
          raise LunaPark::Errors::AbstractMethod
        end

        # @deprecated
        def to_rows(input_array)
          warn 'DEPRECATED! Use `#to_records` instead'
          to_records(input_array)
        end

        # @deprecated
        def to_row(input)
          warn 'DEPRECATED! Use `#to_record` instead'
          to_record(input)
        end

        # @deprecated
        def from_rows(records_array)
          warn 'DEPRECATED! Use `#from_records` instead'
          from_records(records_array)
        end

        # @deprecated
        def from_row(input)
          warn 'DEPRECATED! Use `#from_record` instead'
          from_record(input)
        end
      end
    end
  end
end
