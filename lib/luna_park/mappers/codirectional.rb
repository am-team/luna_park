# frozen_string_literal: true

require 'luna_park/mappers/simple'
require 'luna_park/mappers/codirectional/copiysts/plain'
require 'luna_park/mappers/codirectional/copiysts/nested'

module LunaPark
  module Mappers
    ##
    # DSL for describe Nested Schema translation: entity attributes to database record and vice-versa
    #
    # @example
    #   class Mappers::Transaction < LunaPark::Mappers::Codirectional
    #     map attr: :uid,                 record: :id
    #     map attr: [:charge, :amount],   record: :charge_amount
    #     map attr: [:charge, :currency], record: :charge_currency # using aliased args
    #     map :comment
    #   end
    #
    #   attrs = { charge: { amount: 10, currency: 'USD' }, comment: 'Foobar' }
    #   transaction = Entities::Transaction.new(attrs)
    #
    #   mapper = Mappers::Transaction
    #
    #   # Mapper transforms attr attributes to database record and vice-verse
    #   new_record   = sequel_database_table.insert(record) # => { id:  42, charge_amount: 10, charge_currency: 'USD', comment: 'Foobar' }
    #   record    = mapper.to_record(transaction)           # => {          charge_amount: 10, charge_currency: 'USD', comment: 'Foobar' }
    #   new_attrs = mapper.from_record(new_record)          # => { uid: 42, charge: { amount: 10, currency: 'USD' },   comment: 'Foobar' }
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
        #     map attr: :id,                record: :uid
        #     map attr: [:charge, :amount], record: :charge_amount
        #     map :comment
        #   end
        #
        #   Mappers::Transaction.from_record({ id: 1, charge_amount: 2 })     # => { uid: 1, charge: { amount: 2 } }
        #   Mappers::Transaction.to_record({ uid: 1, charge: { amount: 2 } }) # => { id: 1, charge_amount: 2 }
        def map(*common_keys, attr: nil, record: nil)
          attrs(*common_keys) if common_keys.any?

          self.attr attr, record: record if attr
        end

        # @example
        #   class Mappers::Transaction < LunaPark::Mappers::Codirectional
        #     attr :uid,               record: :id
        #     attr [:charge, :amount], record: :charge_amount
        #   end
        def attr(attr, record: nil)
          return attrs(attr) if record.nil?

          attr_path = to_path(attr)
          record_path  = to_path(record)

          if attr_path == record_path
            attrs(attr_path)
          else
            nested_copyists << Copyists::Nested.new(attrs_path: attr_path, record_path: record_path)
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
              nested_copyists << Copyists::Nested.new(attrs_path: path, record_path: path)
            else
              plain_copyist.add_key(path)
            end
          end
        end

        def from_record(input)
          record = input.to_h
          {}.tap do |attrs|
            plain_copyist.from_record(record: record, attrs: attrs)
            nested_copyists.each { |copyist| copyist.from_record(record: record, attrs: attrs) }
          end
        end

        def to_record(input)
          attrs = input.to_h
          {}.tap do |record|
            plain_copyist.to_record(record: record, attrs: attrs)
            nested_copyists.each { |copyist| copyist.to_record(record: record, attrs: attrs) }
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
