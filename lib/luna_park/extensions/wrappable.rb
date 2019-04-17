# frozen_string_literal: true

module LunaPark
  module Extensions
    ##
    # class-level mixin
    #
    # @example
    #  class Account
    #    extend LunaPark::Extensions::Wrappable
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
    module Wrappable
      def wrap(input)
        case input
        when self then input
        when Hash then new(input)
        else raise Errors::Unwrapable, "#{self} can not wrap #{input.class}"
        end
      end
    end
  end
end
