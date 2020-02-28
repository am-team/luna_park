# frozen_string_literal: true

require 'luna_park/utils/environment'

module LunaPark
  RSpec.describe Utils::Environment do
    subject(:app_env) { described_class.new(env, allowed: allowed_envs) }

    let(:env)          { 'test' }
    let(:allowed_envs) { %i[development test production] }

    describe '.new' do
      it { is_expected.to be_a String }
      it { is_expected.to be_a Utils::Environment }
      it { is_expected.to eq   'test' }

      context 'when given not allowed environment name' do
        let(:env) { 'tesst' }
        it { expect { app_env }.to raise_error 'Not allowed environment: tesst. Allowed: development, test, production' }
      end
    end

    describe '#inspect' do
      subject(:inspect) { app_env.inspect }

      it { is_expected.to eq '#<LunaPark::Utils::Environment test>' }
    end

    describe '#env?' do
      subject(:env?) { app_env.env?(*checkable_envs) }

      let(:checkable_envs) { %i[test development] }

      it { is_expected.to be true }

      context 'when given list without curent env' do
        let(:checkable_envs) { %i[development production] }

        it { is_expected.to be false }
      end

      context 'when given list with not allowed env' do
        let(:checkable_envs) { %i[development proddduction] }

        it { expect { env? }.to raise_error(NoMethodError, /\Aundefined method `proddduction\?'/) }
      end
    end

    describe '#==' do
      context 'when given not String' do
        it 'compares with Symbol' do
          expect(app_env == :test).to be true
        end

        it 'compares with any object with #to_s' do
          expect(app_env == double(to_s: 'test')).to be true
        end
      end
    end
  end
end
