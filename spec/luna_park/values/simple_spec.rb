# frozen_string_literal: true

class Rank < LunaPark::Values::Simple
  LIST = %w[6 7 8 9 10 J Q K A].freeze

  # def <=>(another)
  #
  # end

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
    let(:value) { 'Q' }
    let(:rank)  { Rank.new(value) }

    describe '.value' do
      subject { rank.value }

      it 'is equal value from initializer' do
        is_expected.to eq(value)
      end
    end

    describe '==' do
      context 'when same value' do
        let(:another) { Rank.new(value) }

        it 'is same' do
        end
      end
    end
  end
end
