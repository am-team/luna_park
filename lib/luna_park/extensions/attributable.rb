# frozen_string_literal: true

module LunaPark
  module Extensions
    # @example
    #   class Account
    #     include LunaPark::Extensions::Attributable
    #
    #     attr_accessor :type, :id
    #
    #     def initialize(hash)
    #       set_attributes(hash) # method included by mixin (private)
    #     end
    #   end
    #
    #   Account.new(type: 'user', id: 42) # => #<Account type="user" id=42>
    module Attributable
      private

      def set_attributes(hash) # rubocop:disable Naming/AccessorMethodName
        hash.each { |k, v| send(:"#{k}=", v) }
        self
      end
    end
  end
end
