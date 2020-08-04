# frozen_string_literal: true

require 'luna_park/tools/environment'

module LunaPark
  RSpec.describe Tools::Environment do
    describe '.new' do
      context 'when given allowed environment name,' do
        subject(:new) { described_class.new('test', allowed: %i[development test production]) }

        it { is_expected.to be_a String }
        it { is_expected.to be_a Tools::Environment }
        it { is_expected.to eq   'test' }
      end

      context 'when given not allowed environment name,' do
        subject(:new) { described_class.new('tesst', allowed: %i[development test production]) }

        it { expect { new }.to raise_error 'Not allowed environment: tesst. Allowed: development, test, production' }
      end
    end

    describe '#inspect' do
      subject(:inspect) { env.inspect }
      let(:env) { described_class.new('test', allowed: %i[development test production]) }

      it { is_expected.to eq '#<LunaPark::Tools::Environment test>' }
    end

    describe '#env?' do
      let(:app_env) { described_class.new('test', allowed: %i[development test production]) }

      context 'when given list contained allowed env,' do
        subject(:env?) { app_env.env?(:test, :development) }

        it { is_expected.to be true }
      end

      context 'when given list without current env,' do
        subject(:env?) { app_env.env?(:development, :production) }

        it { is_expected.to be false }
      end

      context 'when given list with not allowed env,' do
        subject(:env?) { app_env.env?(:development, :proddduction) }

        it { expect { env? }.to raise_error(NoMethodError, /\Aundefined method `proddduction\?'/) }
      end
    end

    describe '#==' do
      let(:env) { described_class.new('test', allowed: %i[development test production]) }

      context 'when given not String,' do
        it 'comparable with Symbol' do
          expect(env == :test).to be true
        end

        it 'comparable with any object with #to_s,' do
          expect(env == double(to_s: 'test')).to be true
        end
      end
    end
  end
end
