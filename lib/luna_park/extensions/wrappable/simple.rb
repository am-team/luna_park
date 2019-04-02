# frozen_string_literal: true

module LunaPark
  module Extensions
    module Wrappable
      def self.extended(base)
        base.extend(Simple)
      end

      ##
      # class-level mixin
      #
      # @example
      #  class Card
      #    extend LunaPark::Extensions::Wrappable:Simple
      #
      #    attr_reader :rank
      #
      #    def self.wrap(input)
      #      super do
      #        new(input.to_s) if input.is_a?(Symbol)
      #      end
      #    end
      #
      #    def initialize(rank)
      #      @type = rank
      #    end
      #  end
      #
      #  rank = 'K6'
      #  card = Card.new(rank)
      #
      #  Card.new(card)   # => raise ArgumentError
      #  Card.wrap(card)  # => #<Card rank='K6'>
      #  Card.wrap(rank)  # => #<Card rank='K6'>
      #  Card.wrap(:'K6') # => #<Card rank='K6'>
      #  Card.wrap(6)     # raise 'Card can not wrap Integer'
      #
      #  Card.wrap(account).eql?(account) # => true
      module Simple
        def wrap(input)
          return input if input.is_a?(self)

          if block_given?
            wrapped = yield
            return wrapped if wrapped
          end

          raise Errors::Unwrapable, "#{self} can not wrap #{input.class}"
        end
      end
    end
  end
end
