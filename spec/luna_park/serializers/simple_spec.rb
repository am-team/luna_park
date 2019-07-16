# frozen_string_literal: true

require_relative '../../../lib/luna_park/serializers/simple'

class MySimpleSerializer < LunaPark::Serializers::Simple
  def to_h
    {
      currency: object.currency.to_s,
      fractional: object.fractional.to_i
    }
  end
end

module LunaPark
  RSpec.describe Serializers::Simple do
    subject(:serializer) { sample_class.new(serializable) }

    let(:sample_class) { MySimpleSerializer }
    let(:serializable) { OpenStruct.new(currency: 'КЦ', fractional: 1) }

    describe '#to_h' do
      subject(:to_h) { serializer.to_h }

      it 'returns expected result' do
        is_expected.to eq currency: 'КЦ', fractional: 1
      end
    end

    describe '#to_json' do
      subject(:to_json) { serializer.to_json }

      it 'returns expected JSON' do
        is_expected.to eq JSON[currency: 'КЦ', fractional: 1]
      end
    end
  end
end
