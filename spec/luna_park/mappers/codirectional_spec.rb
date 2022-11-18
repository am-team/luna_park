# frozen_string_literal: true

require 'luna_park/mappers/codirectional'
require 'luna_park/serializers/simple'

module MappersCodirectionalSpec
  class TransactionMapper < LunaPark::Mappers::Codirectional
    attr :uid,                      row: :id
    attr %i[funds charge amount],   row: :funds_charge_amount
    attr %i[funds charge currency], row: :funds_charge_currency
    attr %i[values left]
    attr %i[values right]
    attr :entries, row: :transaction_entries, mapper: 'MappersCodirectionalSpec::EntryMapper'
    attr :comment
  end

  class EntryMapper < LunaPark::Mappers::Codirectional
    attr :uid, row: :id
  end

  class Transaction
    attr_accessor :uid, :funds, :comment

    def initialize(**opts)
      @uid = opts[:uid]
      @funds = Funds.new(opts[:funds])
      @comment = opts[:comment]
      @values = opts[:values]
    end

    def to_h
      { uid: uid, funds: funds.to_h, comment: comment, values: @values.to_h }
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

    let(:values) { { left: 42, right: 176 } }

    let(:attrs) { { uid: 42, funds: { charge: { amount: 10, currency: 'USD' } }, values: values, comment: 'Foobar' } }
    let(:row)   { { id: 42, funds_charge_amount: 10, funds_charge_currency: 'USD', values: values, comment: 'Foobar' } }

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

      context 'when given data for nested mapper' do
        let(:input)           { { comment: 'Foobar', transaction_entries: [{ id: 42 }, { id: 999 }] } }
        let(:expected_output) { { comment: 'Foobar', entries: [{ uid: 42 }, { uid: 999 }] } }

        it 'transforms values at given key paths' do
          is_expected.to eq expected_output
        end
      end
    end

    describe '.from_rows' do
      subject(:from_rows) { mapper.from_rows(input) }

      context 'when given data for nested mapper' do
        let(:input) do
          [
            { comment: 'Foobar1', transaction_entries: [id: 1] },
            { comment: 'Foobar2', transaction_entries: [id: 2] },
            { comment: 'Foobar3', transaction_entries: [id: 3] },
            { comment: 'Foobar4', transaction_entries: [id: 4] }
          ]
        end
        let(:expected_output) do
          [
            { comment: 'Foobar1', entries: [uid: 1] },
            { comment: 'Foobar2', entries: [uid: 2] },
            { comment: 'Foobar3', entries: [uid: 3] },
            { comment: 'Foobar4', entries: [uid: 4] }
          ]
        end

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
