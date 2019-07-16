# frozen_string_literal: true

require_relative '../../../lib/luna_park/extensions/attributable'

RSpec.describe LunaPark::Extensions::Attributable do
  let(:klass) do
    Class.new do
      include LunaPark::Extensions::Attributable

      attr_accessor :foo, :bar

      def attributes=(attrs)
        set_attributes(attrs)
      end
    end
  end

  let(:instance) { klass.new }

  describe '#set_attributes' do
    subject(:set_attributes) { instance.attributes = attributes }

    context 'when right attributes given' do
      let(:attributes) { { foo: 'Foo', bar: 'Bar' } }

      it 'changes #foo' do
        expect { set_attributes }.to change { instance.foo }.from(nil).to('Foo')
      end

      it 'changes #bar' do
        expect { set_attributes }.to change { instance.bar }.from(nil).to('Bar')
      end
    end

    context 'when unknown attribute given'
    context 'when not hash given'
  end
end
