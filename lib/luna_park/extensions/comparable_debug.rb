# frozen_string_literal: true

module LunaPark
  module Extensions
    ##
    # Debug for #== method
    #
    # @example
    #  class Funds
    #    include LunaPark::Extensions::Comparable
    #    include LunaPark::Extensions::ComparableDebug
    #    # ...
    #
    #    comparable_attributes :from, :to
    #    # ...
    #  end
    module ComparableDebug
      ##
      # Returns nested Hash represents full comparsion that contains:
      #   In root:
      #   { `bool` => { ... } } (that describes result of compasrion with detailed cmp in hash value)
      #   AND
      #     { :field_name => { `bool` => ... } } (that describes concrete field comparsion)
      #     OR
      #     { `bool` => [left, right] } } (that describes result of left and right objects compasrion)
      #
      # @example
      #  t1 = Funds.new(from: { charge: { currency: 'USD', amount: 42 } }, usd: { currency: 'USD', amount: 41 })
      #  t2 = Funds.new(from: { charge: { currency: 'USD', amount: 43 } }, usd: { currency: 'USD', amount: 42 })
      #
      #  t1 == t2 # => false
      #
      #  t1.detailed_cmp(t2) # =>
      #    { false => {                                         # (t1 == t2) == false
      #        :from => {                                       #   `#from`
      #          false => {                                     #     (t1.from == t2.from) == false
      #            :account =>                                  #   `#from#account`
      #              { true => [nil, nil] },                    #     (t1.from.account == t2.from.account) == (nil == nil)
      #            :charge => {                                 #   `#from#charge`
      #              false => {                                 #     (t1.from.charge == t2.from.charge) == false
      #                :currency => { true => ["USD", "USD"] }, #       (t1.from.charge.currency == t2.from.charge.currency) == ('USD' == 'USD')
      #                :amount => { false => [42, 43] } } },    #       (t1.from.amount == t2.from.amount) == (42 == 43)
      #            :usd => {                                    #   `#from#usd`
      #              false => {                                 #     (t1.from.usd == t2.from.usd) == false
      #                :currency => { true => ["USD", "USD"] }, #       (t1.from.usd.currency == t2.from.usd.currency) == ('USD' == 'USD')
      #                :amount => { false => [41, 44] } } } }   #       (t1.from.usd.amount == t2.from.usd.amount) == (41 == 44)
      #        }
      #      }
      #    }
      def detailed_comparsion(other)
        diff = self.class.comparable_attributes_list.each_with_object({}) do |field, output|
          left  = send(field)
          right = other&.send(field)

          output[field] = if left.respond_to?(:detailed_comparsion)
                            left.detailed_comparsion(right)
                          else
                            { (left == right) => [left, right] }
                          end
        end

        { (self == other) => diff }
      end

      alias detailed_cmp detailed_comparsion

      ##
      # Returns only different values, that causes missmatch
      #
      # @example
      #   t1 = Funds.new(from: { charge: { currency: 'USD', amount: 42 } }, usd: { currency: 'USD', amount: 41 }, comment: 'Foo')
      #   t2 = Funds.new(from: { charge: { currency: 'USD', amount: 43 } }, usd: { currency: 'USD', amount: 42 }, comment: 'Foo')
      #
      #   t1 == t2 # => false
      #
      #   t1.detailed_diff(t2) # =>
      #    { from: { charge: { amount: [42, 43] } }, usd: { amount: [41, 42] } }
      def detailed_differences(other)
        self.class.comparable_attributes_list.each_with_object({}) do |field, output|
          left  = send(field)
          right = other&.send(field)

          next if left == right

          output[field] = if left.respond_to?(:detailed_differences)
                            left.detailed_differences(right)
                          else
                            [left, right]
                          end
        end
      end

      alias detailed_diff detailed_differences
    end
  end
end
