# frozen_string_literal: true

require 'luna_park/extensions/injector'
require 'luna_park/errors'

module LunaPark
  RSpec.describe Extensions::Injector do
    let!(:fuel_class) { stub_const('Fuel', Class.new) }
    let!(:oil_class)  { stub_const('Oil',  Class.new) }

    let(:engine_class) do
      Class.new do
        include LunaPark::Extensions::Injector

        dependency(:fuel) { Fuel.new }
        dependency(:oil)  { Oil.new }
      end
    end
    let(:engine) { engine_class.new }

    describe '.dependency' do
      it 'sets dependency' do
        expect { engine_class.dependency(:foo) { 'Foo' } }.to change { engine_class.dependencies[:foo] }.from(nil).to Proc
      end

      context 'when no block given' do
        it 'raises ArgumentError' do
          expect { engine_class.dependency(:foo) }.to raise_error ArgumentError, 'no block given'
        end
      end
    end

    describe '.dependencies' do
      context 'on defined class' do
        subject(:dependencies) { engine_class.dependencies }

        it { is_expected.to be_an_instance_of Hash }

        it 'should be eq defined dependencies' do
          is_expected.to have_key :fuel
          is_expected.to have_key :oil
        end
      end

      context 'on child class' do
        let(:rotor_class) { Class.new(engine_class) }
        subject(:dependencies) { rotor_class.dependencies }

        it { is_expected.to be_an_instance_of Hash }

        it 'should be eq defined dependencies' do
          is_expected.to have_key :fuel
          is_expected.to have_key :oil
        end

        it 'Instance shoulde respond to dependencies method' do
          expect(rotor_class.new).to respond_to :fuel
          expect(rotor_class.new).to respond_to :oil
        end
      end
    end

    describe '#dependency' do
      it 'should add class dependency' do
        expect(engine.dependencies[:fuel]).to be_an_instance_of Proc
      end

      it 'should define dependency getter' do
        expect(engine.fuel).to be_an_instance_of Fuel
      end
    end

    describe '.dependencies' do
      subject(:dependencies) { engine_class.dependencies }

      it { is_expected.to be_an_instance_of Hash }

      it 'should be eq defined dependencies' do
        is_expected.to have_key :fuel
        is_expected.to have_key :oil
      end
    end

    describe '#dependencies' do
      subject(:dependencies) { engine.dependencies }

      context 'when dependencies is not defined in the instance' do
        it 'should be eq dependencies defined in class' do
          is_expected.to eq engine_class.dependencies
        end
      end

      context 'when dependencies defined in the instance directly' do
        let(:deps) { { fuel: -> { double }, oil: -> { double } } }

        before { engine.dependencies = deps }

        it 'should be eq defined dependencies' do
          is_expected.to eq deps
        end
      end
    end
  end
end
