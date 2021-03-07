# frozen_string_literal: true

require 'luna_park/mappers/codirectional'
require 'luna_park/serializers/simple'

module MappersCodirectionalSpec
  class TransactionMapper < LunaPark::Mappers::Codirectional
    attr :uid,                      row: :id
    attr %i[funds charge amount],   row: :funds_charge_amount
    attr %i[funds charge currency], row: :funds_charge_currency
    attr %i[sizes waist]
    attr %i[sizes length]
    attr :comment
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
  RSpec.describe Mappers::Codirectional do
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
        let(:input) { MappersCodirectionalSpec::Transaction.new(**attrs) }

        it 'converts object to attributes before mapping' do
          is_expected.to eq row
        end

        it 'uses `#to_h` for converts object to attributes' do
          expect(input).to receive(:to_h).and_call_original
          to_row
        end
      end

      context 'when given not full Hash of attributes,' do
        let(:input)           { { funds: { charge: { currency: 'USD' } }, comment: 'Foobar' } }
        let(:expected_output) { { funds_charge_currency: 'USD', comment: 'Foobar' } }

        it 'transforms values at given key paths' do
          is_expected.to eq expected_output
        end
      end

      context 'when given hash with non-primitives,' do
        let(:input)           { { funds: { charge: MappersCodirectionalSpec::Money.new(amount: 42, currency: 'USD') }, comment: 'Foobar' } }
        let(:expected_output) { { funds_charge_amount: 42, funds_charge_currency: 'USD', comment: 'Foobar' } }

        it { expect { to_row }.to raise_error Mappers::Codirectional::Errors::NotHashGiven }

        it 'raised exception has description' do
          expect(exception { to_row }.message).to start_with(
            'Value at path [:funds, :charge] MUST be a Hash when the root is a Hash, ' \
              'but is a MappersCodirectionalSpec::Money: #<MappersCodirectionalSpec::Money:'
          )
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
        let(:input)           { { funds_charge_currency: 'USD', comment: 'Foobar' } }
        let(:expected_output) { { funds: { charge: { currency: 'USD' } }, comment: 'Foobar' } }

        it 'transforms values at given key paths' do
          is_expected.to eq expected_output
        end
      end
    end

    def exception
      yield
      nil
    rescue Exception => e # rubocop:disable Lint/RescueException
      e
    end
  end
end
