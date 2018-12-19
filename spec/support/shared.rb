# frozen_string_literal: true

require_relative '../../lib/luna_park/errors'

module LunaPark
  shared_examples 'wrap method' do
    context 'when given self type' do
      let(:input) { object }

      it 'returns self type' do
        is_expected.to be_a described_class
      end

      it 'returns given object' do
        is_expected.to be input
      end
    end

    context 'when given Hash' do
      let(:input) { arguments }

      it 'returns self type' do
        is_expected.to be_a described_class
      end
    end

    context 'when given Not a mouse, not a frog, but an unknown creature' do
      let(:input) { [] }

      it 'raises error with expected type' do
        expect { wrap }.to raise_error Errors::Unwrapable
      end

      it 'raises error with expected message' do
        expect { wrap }.to raise_error "Can`t wrap #{input.class}"
      end
    end
  end
end
