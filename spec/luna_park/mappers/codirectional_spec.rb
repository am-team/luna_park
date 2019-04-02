# frozen_string_literal: true

module MappersCodirectionalSpec
  class TransactionMapper < LunaPark::Mappers::Codirectional
    map entity: :uid,                      store: :id
    map entity: %i[funds charge amount],   store: :funds_charge_amount
    map attr:   %i[funds charge currency], row:   :funds_charge_currency
    map %i[sizes waist]
    map %i[sizes length]
    map :comment
  end

  class Transaction
    attr_accessor :uid, :funds, :comment

    def initialize(**opts)
      @uid = opts[:uid]
      @funds = Funds.new(opts[:funds])
      @comment = opts[:comment]
      @sizes = opts[:sizes]
    end

    def to_h
      { uid: uid, funds: funds.to_h, comment: comment, sizes: @sizes.to_h }
    end
  end

  class Funds
    attr_reader :charge, :usd

    def initialize(charge:, usd: nil)
      @charge = Money.new(charge)
      @usd = usd
    end

    def to_h
      { charge: charge.to_h, usd: usd.to_h }
    end
  end

  class Money
    attr_reader :amount, :currency

    def initialize(amount:, currency:)
      @amount = amount
      @currency = currency
    end

    def to_h
      { amount: amount, currency: currency }
    end
  end
end

module LunaPark
  RSpec.describe Serializers::Simple do
    subject(:mapper) { MappersCodirectionalSpec::TransactionMapper }

    let(:sizes) { { waist: 42, length: 176 } }

    let(:attrs) { { uid: 42, funds: { charge: { amount: 10, currency: 'USD' } }, sizes: sizes, comment: 'Foobar' } }
    let(:row)   { { id: 42, funds_charge_amount: 10, funds_charge_currency: 'USD', sizes: sizes, comment: 'Foobar' } }

    describe '.to_row' do
      subject(:to_row) { mapper.to_row(input) }

      let(:input) { attrs }

      it 'transforms nested attributes to row' do
        is_expected.to eq row
      end

      context 'when given object,' do
        let(:input) { MappersCodirectionalSpec::Transaction.new(attrs) }

        it 'works fine' do
          is_expected.to eq row
        end
      end

      context 'when given not full Hash of attributes,' do
        let(:input)  { { funds: { charge: { currency: 'USD' } }, comment: 'Foobar' } }
        let(:output) { { funds_charge_currency: 'USD', comment: 'Foobar' } }

        it 'transforms all that given' do
          is_expected.to eq(funds_charge_currency: 'USD', comment: 'Foobar')
        end
      end

      context 'when given not only primitive attributes,' do
        let(:input)  { { funds: { charge: charge_object }, comment: 'Foobar' } }
        let(:output) { { funds_charge_amount: 42, funds_charge_currency: 'USD', comment: 'Foobar' } }

        let(:charge_object) { MappersCodirectionalSpec::Money.new(amount: 42, currency: 'USD') }

        before { skip 'TODO' }

        it 'transforms all that given' do
          is_expected.to eq output
        end
      end
    end

    describe '.from_row' do
      subject(:from_row) { mapper.from_row(input) }

      let(:input) { row }

      it 'transforms row to nested attributes' do
        is_expected.to eq attrs
      end

      context 'when given not full row,' do
        let(:input)  { { funds_charge_currency: 'USD', comment: 'Foobar' } }
        let(:output) { { funds: { charge: { currency: 'USD' } }, comment: 'Foobar' } }

        it 'transforms all that given' do
          is_expected.to eq output
        end
      end
    end
  end
end
