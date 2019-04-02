# frozen_string_literal: true

module LunaPark
  module Extensions
    module Wrappable
      ##
      # class-level mixin
      #
      # Same as Wrappable::Simple, but sith default Hash mapping
      #
      # @example
      #  class Account
      #    extend LunaPark::Extensions::Wrappable::Hash
      #
      #    attr_reader :type, :id
      #
      #    def self.wrap(input)
      #      super do
      #        if input.is_a?(String)
      #          type, id = input.split(' ')
      #          new(type: type, id: id)
      #        end
      #      end
      #    end
      #
      #    def initialize(type:, id:)
      #      @type, @id = type, id
      #    end
      #  end
      #
      #  hash = { type: 'user', id: 42 }
      #  acccount = Account.new(hash)
      #
      #  Account.new(hash)       # => #<Account type='user' id=42>
      #  Account.new(acccount)   # => raise ArgumentError
      #  Account.wrap(acccount)  # => #<Account type='user' id=42>
      #  Account.wrap(hash)      # => #<Account type='user' id=42>
      #  Account.wrap('user 42') # => #<Account type='user' id=42>
      #  Account.wrap(nil)       # raise 'Account can not wrap NilClass'
      #
      #  Account.wrap(account).eql?(account) # => true
      module Hash
        def self.extended(base)
          base.extend(Simple)
          base.extend(ClassMethods)
        end

        module ClassMethods
          def wrap(input)
            super { new(input) if input.is_a?(::Hash) }
          end
        end
      end
    end
  end
end
