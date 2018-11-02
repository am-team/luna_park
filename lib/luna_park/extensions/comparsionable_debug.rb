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

      def comparsion_attributes
        raise NotImplementedError, 'You must implement this method ' \
          'to return list of attributes (methods) for full comparsion with #== '\
          'and #differences_structure'
      end
    end
  end
end

# {false=>     # сравнение объекта провалено
#   {:from=>   # результат сравнения по объекту в аттрибуте `#from`
#     {false=> # сравнение по объекту в аттрибуте `#from` провалено
#       {:account=>{true=>[nil, nil]}, # сравнение объекта `#from` по его аттрибуду `#account` успешно: nil == nil
#        :charge=> # результат сравнения по объекту в аттрибуте `#from#charge`
#         {false=> # сравнение объекта `#from` по его аттрибуту #charge провалено
#           {:currency=>{true=>["USD", "USD"]}, # сравнение `#from#charge` по аттрибуту `#currency` успешно: 'USD' == 'USD'
#            :amount=>{false=>[42, 43]},        # сравнение `#from#charge` по аттрибуту `#amount` провалено: 42 != 43
#        :usd=>    # результат сравнения по объекту в аттрибуте `#from#usd`
#         {false=> # сравнение по объекту в аттрибуте `#from` провалено
#           {:currency=>{true=>["USD", "USD"]},
#            :amount=>{false=>[41, 44]},
#    :to=>{true=>[nil, nil]},
#    :commission=>
#     {false=>
#       {:charge=>
#         {true=>
#           {:currency=>{true=>["USD", "USD"]},
#            :amount=>{true=>[42, 42]},
#            :fractional=>{true=>[0, 0]}}},
#        :usd=>
#         {false=>
#           {:currency=>{true=>["USD", "USD"]},
#            :amount=>{false=>[41, 42]}}}}}}}}
