# frozen_string_literal: true

module LunaPark
  module Extensions
    module ComparsionableDebug
      # Debug for #== method
      #
      # returns { `bool` => [left, right] } }
      #   that describes result of left and right objects compasrion
      # or { :field_name => { `bool` => ... } }
      #   that describes concrete field comparsion
      #
      # @example
      #   { false =>                                           # obj != other
      #     { :from =>                                         # `.from`
      #       { false =>                                       # obj.from != other.from
      #         { :account =>                                  # `.from.account`
      #           { true => [nil, nil] },                      # obj.from.account == other.from.account # nil == nil
      #          :charge =>                                    # `.from.charge`
      #           { false =>                                   # obj.from.charge != other.from.charge
      #             { :currency => { true => ["USD", "USD"] }, # obj.from.charge == other.from.charge # "USD" == "USD"
      #               :amount => { false => [42, 43] } } }     # obj.from.amount != other.from.amount # 42 != 43
      #          :usd =>                                       # `.from.usd`
      #           { false =>                                   # obj.from.usd != other.from.usd
      #             { :currency => { true => ["USD", "USD"] }, # obj.from.usd.currency == other.from.usd.currency
      #               :amount => { false => [41, 44] } } } } } # obj.from.usd.amount != other.from.usd.amount # 41 != 44
      def differences_structure(other)
        diff = comparsion_attributes.each_with_object({}) do |field, output|
            left, right = self.send(field), other&.send(field)

            if left.respond_to?(:differences_structure)
              output[field] = left.differences_structure(right)
            else
              output[field] = { (left == right) => [left, right] }
            end
          end

        { (self == other) => diff }
      end
    end
  end
end
