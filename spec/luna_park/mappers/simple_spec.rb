# frozen_string_literal: true

require 'luna_park/mappers/simple'

module MappersSimpleSpec
  class TransactionMapper < LunaPark::Mappers::Simple
    def self.from_record(record)
      {
        charge: {
          fractional: record[:charge_fractional],
          currency: record[:charge_currency]
        }
      }
    end

    def self.to_record(record)
      {
        charge_fractional: record.dig(:charge, :fractional),
        charge_currency: record.dig(:charge, :currency)
      }
    end
  end
end

module LunaPark
  RSpec.describe Mappers::Simple do
    let(:abstract_mapper) { LunaPark::Mappers::Simple }
    let(:sample_mapper) { MappersSimpleSpec::TransactionMapper }

    let(:record)   { { charge_fractional: 100, charge_currency: 'USD' } }
    let(:attrs) { { charge: { fractional: 100, currency: 'USD' } } }

    describe '.from_record' do
      it { expect { abstract_mapper.from_record(record) }.to raise_error Errors::AbstractMethod }
    end

    describe '.to_record' do
      it { expect { abstract_mapper.to_record(attrs) }.to raise_error Errors::AbstractMethod }
    end

    describe '.from_records' do
      subject(:from_records) { sample_mapper.from_records([record, record]) }

      it 'transforms array' do
        is_expected.to eq [attrs, attrs]
      end

      context 'when not an Array given' do
        subject(:from_records) { sample_mapper.from_records('Foo') }

        it 'raises exception' do
          expect { from_records }.to raise_error Mappers::Errors::NotArray
        end

        it 'raises meaningfull exception' do
          expect { from_records }.to raise_error 'input MUST be an Array, but given String `"Foo"`'
        end
      end
    end

    describe '.to_records' do
      subject(:from_records) { sample_mapper.to_records([attrs, attrs]) }

      it 'transforms array' do
        is_expected.to eq [record, record]
      end

      context 'when not an Array given' do
        subject(:to_records) { sample_mapper.to_records('Foo') }

        it 'raises exception' do
          expect { to_records }.to raise_error Mappers::Errors::NotArray
        end

        it 'raises meaningfull exception' do
          expect { to_records }.to raise_error 'input MUST be an Array, but given String `"Foo"`'
        end
      end
    end
  end
end
