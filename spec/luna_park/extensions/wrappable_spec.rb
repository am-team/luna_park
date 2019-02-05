# frozen_string_literal: true

module ExtensionsWrappableSpec
  Account = Struct.new(:type, :uid, keyword_init: true) do
    extend LunaPark::Extensions::Wrappable
  end
end

module LunaPark
  RSpec.describe Extensions::Callable do
    subject(:wrap) { klass.wrap(input) }

    let(:klass) { ExtensionsWrappableSpec::Account }

    context 'when given object,' do
      let(:input) { klass.new(type: 'user', uid: '42') }

      it 'returns this object' do
        is_expected.to be input
      end
    end

    context 'when given Hash,' do
      let(:input) { klass.new(attrs) }
      let(:attrs) { { type: 'user', uid: '42' } }

      it 'returns new object with given attributes' do
        expect(wrap.to_h).to eq attrs
      end
    end

    context 'when given unknown type,' do
      let(:input) { nil }

      it 'raises meaningfull exception' do
        expect { wrap }.to raise_error Errors::Unwrapable, 'ExtensionsWrappableSpec::Account can not wrap NilClass'
      end
    end
  end
end
