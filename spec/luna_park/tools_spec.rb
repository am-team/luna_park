# frozen_string_literal: true

require 'luna_park/tools'

module LunaPark
  RSpec.describe Tools do
    describe '.if_gem_installed' do
      context 'when gem is installed' do
        it { expect(described_class.if_gem_installed('rspec') { 1 + 1 }).to eq true }

        it 'runs code in block' do
          msg = 'Old value'
          expect do
            described_class.if_gem_installed('rspec') { msg = 'New value' }
          end.to change { msg }.from('Old value').to('New value')
        end
      end

      context 'when gem is installed but with wrong version' do
        it { expect(described_class.if_gem_installed('rspec', '< 2') { 1 + 1 }).to eq false }

        it 'does not run code in block' do
          msg = 'Old value'
          expect do
            described_class.if_gem_installed('rspec', '< 2') { msg = 'New value' }
          end.not_to change { msg }.from('Old value')
        end
      end

      context 'when gem does not installed' do
        it { expect(described_class.if_gem_installed('unknown') { 1 + 1 }).to eq false }

        it 'does not run code in block' do
          msg = 'Old value'
          expect do
            described_class.if_gem_installed('unknown') { msg = 'New value' }
          end.not_to change { msg }.from('Old value')
        end
      end
    end
  end
end
