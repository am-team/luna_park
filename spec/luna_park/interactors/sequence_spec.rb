# frozen_string_literal: true

require_relative '../../../lib/luna_park/interactors/sequence'

require_relative '../../../lib/luna_park/entities/simple'

class Pie < LunaPark::Entities::Simple
  attr_accessor :filler

  def ==(other)
    filler == other.filler
  end
end

class MakingApplePie < LunaPark::Interactors::Sequence
  def call!
    @pie = Pie.new(filler: :apple)
  end
end

class MakingBurnedPie < MakingApplePie
  def call!
    raise LunaPark::Errors::Processing, 'Pie is burn out'
  end
end

module LunaPark
  RSpec.describe Interactors::Sequence do
    let(:correct_result) { Pie.new(filler: :apple) }
    let(:sequence)       { klass.new }

    context 'without process errors' do
      let(:klass) { MakingApplePie }

      describe '#call!' do
        subject { sequence.call! }
        it 'should return correct answer' do
          is_expected.to eq correct_result
        end
      end

      describe '#call' do
        subject { sequence.call }
        it { is_expected.to be sequence }
      end

      describe '#data' do
        subject { sequence.data }

        context 'before call' do
          it { is_expected.to be nil }
        end

        context 'after call' do
          before { sequence.call }

          it { is_expected.to eq correct_result }
        end
      end

      describe '#fail?' do
        subject { sequence.fail? }

        context 'before call' do
          it { is_expected.to eq false }
        end

        context 'after call' do
          before { sequence.call }

          it { is_expected.to eq false }
        end
      end

      describe '#success?' do
        subject { sequence.success? }

        context 'before call' do
          it { is_expected.to eq false }
        end

        context 'after call' do
          before { sequence.call }

          it { is_expected.to eq true }
        end
      end

      describe '#call' do
        subject { klass.call }

        it { is_expected.to be_an_instance_of klass }

        it 'is already success' do
          expect(subject.success?).to eq true
        end
      end

      describe '#failure' do
        subject(:failure) { sequence.failure }

        context 'before call' do
          it { is_expected.to be_nil }
        end

        context 'after call' do
          before { sequence.call }

          it { is_expected.to be_nil }
        end
      end
    end

    context 'when process failed' do
      let(:klass) { MakingBurnedPie }

      describe '#call!' do
        subject { sequence.call! }
        it 'raise Errors::Process' do
          expect { subject }.to raise_error Errors::Processing
        end
      end

      describe '#call' do
        subject { sequence.call }
        it      { is_expected.to be sequence }
      end

      describe '#data' do
        subject { sequence.data }

        context 'before call' do
          it { is_expected.to be nil }
        end

        context 'after call' do
          before { sequence.call }

          it { is_expected.to eq nil }
        end
      end

      describe '#fail?' do
        subject { sequence.fail? }

        context 'before call' do
          it { is_expected.to eq false }
        end

        context 'after call' do
          before { sequence.call }

          it { is_expected.to eq true }
        end
      end

      describe '#success?' do
        subject { sequence.success? }

        context 'before call' do
          it { is_expected.to eq false }
        end

        context 'after call' do
          before { sequence.call }

          it { is_expected.to eq false }
        end
      end

      describe '#failure' do
        subject(:failure) { sequence.failure }

        context 'before call' do
          it { is_expected.to be_nil }
        end

        context 'after call' do
          before { sequence.call }

          it { is_expected.to be_a LunaPark::Errors::Processing }
        end
      end

      describe '#call' do
        subject { klass.call }

        it { is_expected.to be_an_instance_of klass }

        it 'is already success' do
          expect(subject.success?).to eq false
        end
      end
    end
  end
end
