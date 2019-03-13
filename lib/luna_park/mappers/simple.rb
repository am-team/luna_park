# frozen_string_literal: true

module LunaPark
  module Mappers
    # Abstract mapper for transform data from Entity attributes schema to Database row schema
    # @example
    #   class Entities::Transaction < LunaPark::Entities::Nested
    #     attr :uid
    #     attr :charge, Money, :wrap
    #     attr :comment
    #   end
    #
    #   class Money < LunaPark::Values::Compound
    #     attr_accessor :amount, :currency
    #   end
    #
    #   class Mappers::Transaction < LunaPark::Mappers::Simple
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
    #   # Entity has concrete attributes schema
    #   attributes  = { charge: { amount: 10, currency: 'USD' }, comment: 'FooBar' }
    #   transaction = Entities::Transaction.new(attributes)
    #   transaction      # => #<Entities::Transaction charge=#<Money amount=10 currency="USD"> comment="FooBar">
    #   transaction.to_h # => # { charge: { amount: 10, currency: 'USD' }, comment: 'FooBar' }
    #   transaction.to_h == attributes # => true
    #
    #   # Mapper transforms entity attributes to database row
    #   row = Mappers::Transaction.to_row(transaction.to_h)
    #   sequel_database_table.insert(row)
    #
    #   # Mapper also transforms database row to entity attributes
    #   row = sequel_database_table.where(id: 42)
    #   attributes  = Mappers::Transaction.from_row(row)
    #   transaction = Entities::Transaction.new(attributes)
    class Simple
      class << self
        def from_rows(hashes)
          return [] if hashes.nil?

          hashes.to_a.map { |hash| from_row(hash) }
        end

        def to_rows(entities)
          return [] if entities.nil?

          entities.to_a.map { |entity| to_row(entity) }
        end

        def from_row(_hash)
          raise NotImplementedError
        end

        def to_row(_entity)
          raise NotImplementedError
        end
      end
    end
  end
end
