# frozen_string_literal: true

class Rank < LunaPark::Values::Simple
  LIST = %w[6 7 8 9 10 J Q K A].freeze

  def to_s
    value
  end

  class << self
    def wrap(obj)
      case obj
      when String then new(obj)
      else super
      end
    end
  end
end

module LunaPark
  RSpec.describe Values::Simple do
    let(:value)        { 'Q' }
    let(:sample_klass) { Rank }
    let(:rank)         { sample_klass.new(value) }

    describe '.wrap' do
      subject(:wrap) { sample_klass.wrap(input) }

      let(:object)    { rank }
      let(:arguments) { value }

      include_examples 'wrap method'
    end

    describe '#value' do
      subject { rank.value }

      it 'is equal value from initializer' do
        is_expected.to eq(value)
      end
    end

    describe '==' do
      subject(:eq) { rank == other }

      context 'when same value' do
        let(:other) { Rank.new(value) }

        it { is_expected.to be true }
      end

      context 'when not same value' do
        let(:other) { Rank.new(value * 2) }

        it { is_expected.to be false }
      end
    end
  end
end
