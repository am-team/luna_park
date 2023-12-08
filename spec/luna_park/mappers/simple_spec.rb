# frozen_string_literal: true

require 'luna_park/mappers/simple'

module MappersSimpleSpec
  class TransactionMapper < LunaPark::Mappers::Simple
    def self.from_row(row)
      {
        charge: {
          fractional: row[:charge_fractional],
          currency: row[:charge_currency]
        }
      }
    end

    def self.to_row(row)
      {
        charge_fractional: row.dig(:charge, :fractional),
        charge_currency: row.dig(:charge, :currency)
      }
    end
  end
end

module LunaPark
  RSpec.describe Mappers::Simple do
    let(:abstract_mapper) { LunaPark::Mappers::Simple }
    let(:sample_mapper) { MappersSimpleSpec::TransactionMapper }

    let(:row)   { { charge_fractional: 100, charge_currency: 'USD' } }
    let(:attrs) { { charge: { fractional: 100, currency: 'USD' } } }

    describe '.from_row' do
      it { expect(abstract_mapper.from_row(row)).to eq row }
    end

    describe '.to_row' do
      it { expect(abstract_mapper.to_row(attrs)).to eq attrs }
    end

    describe '.from_rows' do
      subject(:from_rows) { sample_mapper.from_rows([row, row]) }

      it 'transforms array' do
        is_expected.to eq [attrs, attrs]
      end

      context 'when not an Array given' do
        subject(:from_rows) { sample_mapper.from_rows('Foo') }

        it 'raises exception' do
          expect { from_rows }.to raise_error Mappers::Errors::NotArray
        end

        it 'raises meaningfull exception' do
          expect { from_rows }.to raise_error 'input MUST respond to #to_a, but given String `"Foo"`'
        end
      end
    end

    describe '.to_rows' do
      subject(:from_rows) { sample_mapper.to_rows([attrs, attrs]) }

      it 'transforms array' do
        is_expected.to eq [row, row]
      end

      context 'when not an Array given' do
        subject(:to_rows) { sample_mapper.to_rows('Foo') }

        it 'raises exception' do
          expect { to_rows }.to raise_error Mappers::Errors::NotArray
        end

        it 'raises meaningfull exception' do
          expect { to_rows }.to raise_error 'input MUST respond to #to_a, but given String `"Foo"`'
        end
      end
    end
  end
end
