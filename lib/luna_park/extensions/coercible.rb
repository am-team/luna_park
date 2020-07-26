# frozen_string_literal: true

require 'luna_park/errors'

module LunaPark
  module Extensions
    ##
    # class-level mixin
    #
    # @example
    #  class Account
    #    extend LunaPark::Extensions::Coercible
    #
    #    coercion Hash   { |hash|   new(**hash) } # ? it's a very common situation, so it can be somehow predefined
    #    coercion String { |string| new(**JSON.parse(string)) }
    #
    #    attr_reader :type, :id
    #
    #    def initialize(type:, id:)
    #      @type, @id = type, id
    #    end
    #  end
    #
    #  hash = { type: 'user', id: 42 }
    #  acccount = Account.new(hash)
    #
    #  Account.new(hash)      # => #<Account type='user', id=42>
    #  Account.new(acccount)  # => raise ArgumentError
    #  Account.wrap(hash)     # => #<Account type='user', id=42>
    #  Account.wrap(acccount) # => #<Account type='user', id=42>
    #  Account.wrap(nil)      # raise 'Account can not wrap NilClass'
    #
    #  Account.wrap(account).eql?(account) # => true
    module Coercible
      def coercion(type, &block)
        coercions[type] = block
      end

      def coerce(input)
        return input if input.is_a?(self)
        return input if input.nil?

        return coercions.fetch(input.class).call(input) if coercions.key?(input.class)

        coercions.each_pair do |type, wrapping|
          return wrapping.call(input) if type === input
        end

        raise Errors::Uncoercible.new(input: input, klass: self, types: [self, nil, **coercions.keys])
      end

      alias []   coerce
      alias wrap coerce

      private

      def coercions
        @coercions ||= {}
      end

      module Errors
        class Uncoercible < StandardError
          attr_reader :klass, :input, :types

          def initialize(msg = nil, input:, klass:, types:)
            @input = input
            @klass = klass
            @types = types
            super(msg || build_message)
          end

          def build_message
            "#{klass} can not coerce #{input.class}. It can coerce #{types.join(', ')}"
          end
        end
      end
    end
  end
end
