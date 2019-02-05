# frozen_string_literal: true

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

    context 'when given Not a mouse, not a frog, but an unknown creature' do
      let(:input) { Class.new }

      it 'raises error with expected type' do
        expect { wrap }.to raise_error Errors::Unwrapable
      end

      it 'raises error with expected message' do
        expect { wrap }.to raise_error LunaPark::Errors::Unwrapable, "#{object.class} can not wrap #{input.class}"
      end
    end
  end
end
