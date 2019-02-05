# frozen_string_literal: true

class SampleMoney < LunaPark::Values::Compound
  attr_reader :currency, :fractional

  private

  attr_writer :currency, :fractional
end

module LunaPark
  RSpec.describe Values::Compound do
    let(:arguments)    { { currency: 'КЦ', fractional: 1 } }
    let(:sample_class) { SampleMoney }
    let(:money)        { sample_class.new(arguments) }

    describe '.wrap' do
      subject(:wrap) { sample_class.wrap(input) }

      let(:object) { money }

      include_examples 'wrap method'

      context 'when given Hash' do
        let(:input) { arguments }

        it 'returns self type' do
          is_expected.to be_a described_class
        end
      end
    end

    describe '#==' do
      subject(:eq) { money == other }
      let(:other) { sample_class.new(arguments) }

      it { expect { eq }.to raise_error Errors::AbstractMethod }
    end
  end
end
