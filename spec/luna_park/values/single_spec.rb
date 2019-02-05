# frozen_string_literal: true

class CardRank < LunaPark::Values::Single
  LIST = %w[6 7 8 9 10 J Q K A].freeze

  def initialize(arg)
    arg = arg.to_s
    raise "Unknown rank #{arg}" unless LIST.include?(arg)

    super(arg)
  end

  class << self
    def wrap(input)
      input.is_a?(String) ? new(input) : super
    end
  end
end

module LunaPark
  RSpec.describe Values::Single do
    let(:value)        { 'Q' }
    let(:sample_class) { CardRank }
    let(:rank)         { sample_class.new(value) }

    describe '.wrap' do
      subject(:wrap) { sample_class.wrap(input) }

      let(:object)    { rank }
      let(:arguments) { value }

      include_examples 'wrap method'
    end

    describe '#value' do
      subject(:serialize) { rank.serialize }

      it 'is equal value from initializer' do
        is_expected.to eq value
      end
    end

    describe '#to_s' do
      let(:value)    { 6 }
      subject(:to_s) { rank.to_s }

      it 'is equal value.to_s' do
        is_expected.to eq value.to_s
      end
    end

    describe '#inspect' do
      subject(:inspect) { rank.inspect }

      it 'returns expected string' do
        is_expected.to eq "#<#{sample_class.name} #{rank.serialize.inspect}>"
      end
    end

    describe '==' do
      subject(:eq) { rank == other }

      context 'when same value' do
        let(:other) { sample_class.new(value) }

        it { is_expected.to be true }
      end

      context 'when not same value' do
        let(:other) { sample_class.new('J') }

        it { is_expected.to be false }
      end
    end
  end
end
