# frozen_string_literal: true

require 'luna_park/mappers/simple'
require 'luna_park/mappers/codirectional/copiysts/plain'
require 'luna_park/mappers/codirectional/copiysts/nested'

module LunaPark
  module Mappers
    ##
    # DSL for describe Nested Schema translation: entity attributes to database row and vice-versa
    #
    # @example
    #   class Mappers::Transaction < LunaPark::Mappers::Codirectional
    #     map attr: :uid,                 row: :id
    #     map attr: [:charge, :amount],   row: :charge_amount
    #     map attr: [:charge, :currency], row: :charge_currency # using aliased args
    #     map :comment
    #   end
    #
    #   attrs = { charge: { amount: 10, currency: 'USD' }, comment: 'Foobar' }
    #   transaction = Entities::Transaction.new(attrs)
    #
    #   mapper = Mappers::Transaction
    #
    #   # Mapper transforms attr attributes to database row and vice-verse
    #   new_row   = sequel_database_table.insert(row) # => { id:  42, charge_amount: 10, charge_currency: 'USD', comment: 'Foobar' }
    #   row    = mapper.to_row(transaction)           # => {          charge_amount: 10, charge_currency: 'USD', comment: 'Foobar' }
    #   new_attrs = mapper.from_row(new_row)          # => { uid: 42, charge: { amount: 10, currency: 'USD' },   comment: 'Foobar' }
    #
    #   transaction.set_attributes(new_attrs)
    #   transaction.to_h # => { uid: 42, charge: { amount: 10, currency: 'USD' }, comment: 'Foobar' }
    class Codirectional < Simple
      class << self
        ##
        # Describe translation between two schemas: attr and table
        #
        # @example
        #   class Mappers::Transaction < LunaPark::Mappers::Codirectional
        #     map attr: :id,                row: :uid
        #     map attr: [:charge, :amount], row: :charge_amount
        #     map :comment
        #   end
        #
        #   Mappers::Transaction.from_row({ id: 1, charge_amount: 2 })     # => { uid: 1, charge: { amount: 2 } }
        #   Mappers::Transaction.to_row({ uid: 1, charge: { amount: 2 } }) # => { id: 1, charge_amount: 2 }
        def map(*common_keys, attr: nil, row: nil)
          attrs(*common_keys) if common_keys.any?

          self.attr attr, row: row if attr
        end

        # @example
        #   class Mappers::Transaction < LunaPark::Mappers::Codirectional
        #     attr :uid,               row: :id
        #     attr [:charge, :amount], row: :charge_amount
        #   end
        def attr(attr, row: nil)
          return attrs(attr) if row.nil?

          attr_path = to_path(attr)
          row_path  = to_path(row)

          if attr_path == row_path
            attrs(attr_path)
          else
            nested_copyists << Copyists::Nested.new(attrs_path: attr_path, row_path: row_path)
          end
        end

        # @example
        #   class Mappers::Transaction < LunaPark::Mappers::Codirectional
        #     attrs :comment, [:adresses, :home]
        #   end
        def attrs(*common_keys)
          common_keys.each do |common_key|
            path = to_path(common_key)
            if path.is_a?(Array)
              nested_copyists << Copyists::Nested.new(attrs_path: path, row_path: path)
            else
              plain_copyist.add_key(path)
            end
          end
        end

        def from_row(input)
          row = input.to_h
          {}.tap do |attrs|
            plain_copyist.from_row(row: row, attrs: attrs)
            nested_copyists.each { |copyist| copyist.from_row(row: row, attrs: attrs) }
          end
        end

        def to_row(input)
          attrs = input.to_h
          {}.tap do |row|
            plain_copyist.to_row(row: row, attrs: attrs)
            nested_copyists.each { |copyist| copyist.to_row(row: row, attrs: attrs) }
          end
        end

        private

        # @example
        #   to_path :email              # => :email
        #   to_path ['email']           # => :email
        #   to_path [:charge, 'amount'] # => [:charge, :amount]
        def to_path(input, full: input)
          case input
          when Symbol then input
          when String then input.to_sym
          when Array
            return to_path(input.first, full: full) if input.size <= 1

            input.flat_map { |elem| to_path(elem, full: full) }
          else raise ArgumentError, "Unexpected path part `#{input.inspect}` in `#{full.inspect}`. " \
                                    'Expected Symbol, String or Array'
          end
        end

        def plain_copyist
          @plain_copyist ||= Copyists::Plain.new
        end

        def nested_copyists
          @nested_copyists ||= []
        end
      end
    end
  end
end
