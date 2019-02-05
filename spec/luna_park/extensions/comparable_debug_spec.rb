# frozen_string_literal: true

module ExtensionsComparableDebugSpec
  class Money
    include LunaPark::Extensions::Comparable
    include LunaPark::Extensions::ComparableDebug

    attr_reader :currency, :amount

    comparable_attributes :currency, :amount

    def initialize(hash)
      @currency = hash[:currency]
      @amount   = hash[:amount]
    end
  end

  class Src
    include LunaPark::Extensions::Comparable
    include LunaPark::Extensions::ComparableDebug

    attr_reader :charge, :account

    comparable_attributes :account, :charge

    def initialize(hash)
      @charge = Money.new(hash[:charge])
      @account = hash[:account]
    end
  end

  class Transaction
    include LunaPark::Extensions::Comparable
    include LunaPark::Extensions::ComparableDebug

    attr_reader :from, :usd

    comparable_attributes :from, :usd

    def initialize(hash)
      @from = Src.new(hash[:from])
      @usd = Money.new(hash[:usd])
    end
  end
end

module LunaPark
  RSpec.describe Extensions::Comparable do
    let(:klass) { ExtensionsComparableDebugSpec::Transaction }

    let(:t1) { klass.new(from: { charge: { currency: 'USD', amount: 42 } }, usd: { currency: 'USD', amount: 41 }) }
    let(:t2) { klass.new(from: { charge: { currency: 'USD', amount: 43 } }, usd: { currency: 'USD', amount: 42 }) }

    describe '#detailed_differences' do
      subject(:detailed_differences) { t1.detailed_differences(t2) }

      it 'returns full differencess structure' do
        is_expected.to eq(from: { charge: { amount: [42, 43] } }, usd: { amount: [41, 42] })
      end
    end

    # rubocop:disable Style/HashSyntax, Layout/AlignHash, Layout/MultilineHashBraceLayout, Layout/SpaceAroundOperators, Style/WordArray
    describe '#detailed_comparsion' do
      subject(:detailed_comparsion) { t1.detailed_comparsion(t2) }

      it 'returns full comparsion structure' do
        is_expected.to eq(
          false =>                                              # (t1 == t2) == false
            { :from =>                                          #   `#from`
              { false => {                                      #     (t1.from == t2.from) == false
                :account =>                                     #   `#from#account`
                  { true => [nil, nil] },                       #     (t1.from.account == t2.from.account) == (nil == nil)
                :charge =>                                      #   `#from#charge`
                  { false =>                                    #     (t1.from.charge == t2.from.charge) == false
                    { :currency => { true => ['USD', 'USD'] },  #       (t1.from.charge.currency == t2.from.charge.currency) == ('USD' == 'USD')
                      :amount => { false => [42, 43] } } } } }, #       (t1.from.amount == t2.from.amount) == (42 == 43)
                :usd =>                                         #   `#from#usd`
                  { false =>                                    #     (t1.from.usd == t2.from.usd) == false
                    { :currency => { true => ['USD', 'USD'] },  #       (t1.from.usd.currency == t2.from.usd.currency) == ('USD' == 'USD')
                      :amount => { false => [41, 42] } } } }    #       (t1.from.usd.amount == t2.from.usd.amount) == (41 == 44)
        )
      end
    end
    # rubocop:enable Style/HashSyntax, Layout/AlignHash, Layout/MultilineHashBraceLayout, Layout/SpaceAroundOperators, Style/WordArray
  end
end
