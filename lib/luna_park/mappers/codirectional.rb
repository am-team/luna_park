# frozen_string_literal: true

module LunaPark
  module Mappers
    ##
    # DSL for describe Nested Schema translation: entity attributes to database row and vice-versa
    #
    # @example
    #   class Mappers::Transaction < LunaPark::Mappers::Codirectional
    #     map entity: :uid,                 store: :id
    #     map entity: [:charge, :amount],   store: :charge_amount
    #     map entity: [:charge, :currency], store: :charge_currency
    #     map :comment
    #   end
    #
    #   attrs = { charge: { amount: 10, currency: 'USD' }, comment: 'Foobar' }
    #   transaction = Entities::Transaction.new(attrs)
    #
    #   mapper = Mappers::Transaction
    #
    #   # Mapper transforms entity attributes to database row and vice-verse
    #   row       = mapper.to_row(transaction)        # => { charge_amount: 10, charge_currency: 'USD', comment: 'Foobar' }
    #   new_row   = sequel_database_table.insert(row) # => { id: 42, charge_amount: 10, charge_currency: 'USD', comment: 'Foobar' }
    #   new_attrs = mapper.from_row(new_row)          # => { uid: 42, charge: { amount: 10, currency: 'USD' }, comment: 'Foobar' }
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
          @copyists << Copyists::Simple.new(common_keys)                          if common_keys.any?
          @copyists << Copyists::Nested.new(store_path: store, attr_path: entity) if store && entity
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

      module Copyists
        class Simple
          def initialize(keys)
            @keys = keys
          end

          def from_row(row:, attrs:)
            attrs.merge! row.slice(*@keys)
          end

          def to_row(row:, attrs:)
            row.merge! attrs.slice(*@keys)
          end
        end

        class Nested
          def initialize(store_path:, attr_path:)
            @store_path = store_path
            @attr_path = attr_path

            raise 'store path can not be nil' if store_path.nil?
            raise 'attr path can not be nil' if attr_path.nil?
          end

          def from_row(row:, attrs:)
            copy_nested(from: row, to: attrs, from_path: @store_path, to_path: @attr_path)
          end

          def to_row(row:, attrs:)
            copy_nested(from: attrs, to: row, from_path: @attr_path, to_path: @store_path)
          end

          private

          def copy_nested(from:, to:, from_path:, to_path:) # rubocop:disable Metrics/MethodLength:
            value = if from_path.is_a?(Array)
                      *path, head_key = from_path
                      hash = from.dig(*path)
                      return unless hash&.key?(head_key)

                      hash.fetch(head_key)
                    else
                      return unless from.key?(from_path)

                      from.fetch(from_path)
                    end

            if to_path.is_a?(Array)
              write_to_hested_hash(to, to_path, value)
            else
              to[to_path] = value
            end
          end

          def write_to_hested_hash(hash, full_path, value)
            *path, key = full_path
            prepare_nested_hash(hash, path)[key] = value
          end

          def prepare_nested_hash(nested_hash, path)
            path.inject(nested_hash) { |hash, key| hash[key] ||= {} }
          end
        end
      end
    end
  end
end
