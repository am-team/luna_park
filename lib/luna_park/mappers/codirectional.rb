# frozen_string_literal: true

require 'luna_park/mappers/simple'
require 'luna_park/mappers/codirectional/copiysts/symmetric'
require 'luna_park/mappers/codirectional/copiysts/asymmetric'

module LunaPark
  module Mappers
    ##
    # DSL for describe Asymmetric Schema translation: entity attributes to database row and vice-versa
    #
    # @example
    #   class Mappers::Transaction < LunaPark::Mappers::Codirectional
    #     map entity: :uid,                 store: :id
    #     map entity: [:charge, :amount],   store: :charge_amount
    #     map attr:   [:charge, :currency], row:   :charge_currency # using aliased args
    #     map :comment
    #   end
    #
    #   attrs = { charge: { amount: 10, currency: 'USD' }, comment: 'Foobar' }
    #   transaction = Entities::Transaction.new(attrs)
    #
    #   mapper = Mappers::Transaction
    #
    #   # Mapper transforms entity attributes to database row and vice-verse
    #   row       = mapper.to_row(transaction)        # => {          charge_amount: 10, charge_currency: 'USD', comment: 'Foobar' }
    #   new_row   = sequel_database_table.insert(row) # => { id:  42, charge_amount: 10, charge_currency: 'USD', comment: 'Foobar' }
    #   new_attrs = mapper.from_row(new_row)          # => { uid: 42, charge: { amount: 10, currency: 'USD' },   comment: 'Foobar' }
    #
    #   transaction.set_attributes(new_attrs)
    #   transaction.to_h # => { uid: 42, charge: { amount: 10, currency: 'USD' }, comment: 'Foobar' }
    class Codirectional < Simple
      class << self
        ##
        # Describe translation between two schemas: entity and table
        # `entity:` has alias `attr:`,
        # `store:` has aliases `row:` (for relational db)
        #
        # @example
        #   class Mappers::Transaction < LunaPark::Mappers::Codirectional
        #     map entity: :uid,               store: :id
        #     map entity: [:charge, :amount], store: :charge_amount
        #     map :comment
        #   end
        #
        #   Mappers::Transaction.to_row({ uid: 1, charge: { amount: 2 } }) # => { id: 1, charge_amount: 2 }
        #   Mappers::Transaction.from_row({ id: 1, charge_amount: 2 }) # => { uid: 1, charge: { amount: 2 } }
        def map(*common_keys, row: nil, attr: nil, store: row, entity: attr)
          @copyists ||= []
          @copyists << Copyists::Symmetric.new(common_keys)                           if common_keys.any?
          @copyists << Copyists::Asymmetric.new(store_path: store, attr_path: entity) if store && entity
        end

        def from_row(input)
          row = input.to_h
          attrs = {}
          @copyists&.each { |copyist| copyist.from_row(row: row, attrs: attrs) }
          attrs
        end

        def to_row(input)
          attrs = input.to_h
          row = {}
          @copyists&.each { |copyist| copyist.to_row(row: row, attrs: attrs) }
          row
        end
      end
    end
  end
end
