# frozen_string_literal: true

module LunaPark
  RSpec.describe UseCases::Command do
    class ForestGump
      # in ft
      attr_accessor :distance_he_ran

      def initialize
        @distance_he_ran = 0
      end
    end

    class RunForest < UseCases::Command
      def initialize(forest, distance: 1)
        @forest   = forest
        @distance = distance
      end

      private

      attr_reader :forest, :distance

      def execute
        forest.distance_he_ran += 1
      end
    end

    let(:processed_object) { ForestGump.new }
    let(:process_class)    { RunForest }
    let(:process_instance) { process_class.new(processed_object) }

    shared_examples 'processor change object' do
      it 'was changed object' do
        expect { subject }.to change { processed_object.distance_he_ran }.by(1)
      end
    end

    shared_examples 'processor does not change object' do
      it 'was changed object' do
        expect { subject }.to_not change { processed_object.distance_he_ran }
      end
    end

    shared_examples 'processor fail' do
      it 'was raise `Processing` error' do
        expect { subject }.to raise_error(Errors::Processing)
      end
    end

    shared_examples 'processor error' do
      it 'was raise `StandardError` error' do
        expect { subject }.to raise_error(StandardError)
      end
    end

    describe '.call' do
      subject { process_instance.call }

      it { is_expected.to be true }
      it_behaves_like 'processor change object'
    end

    describe '.call!' do
      subject { process_instance.call! }

      it { is_expected.to be true }
      it_behaves_like 'processor change object'
    end

    describe '#call' do
      subject { process_class.call processed_object }

      it { is_expected.to be true }
      it_behaves_like 'processor change object'
    end

    describe '#call!' do
      subject { process_class.call! processed_object }

      it { is_expected.to be true }
      it_behaves_like 'processor change object'
    end

    context 'when process has fail' do
      class RunHolidayForest < RunForest
        private

        def execute
          raise Errors::Processing, 'I have a day off'
        end
      end

      let(:process_class) { RunHolidayForest }

      describe '.call' do
        subject(:call) { process_instance.call }

        it { is_expected.to be false }
        it { expect { call }.not_to raise_error }
        it_behaves_like 'processor does not change object'
      end

      describe '.call!' do
        subject { process_instance.call! }
        it_behaves_like 'processor fail'
      end

      describe '#call' do
        subject { process_class.call processed_object }

        it { is_expected.to be false }
        it_behaves_like 'processor does not change object'
      end

      describe '#call!' do
        subject { process_class.call! processed_object }
        it_behaves_like 'processor fail'
      end
    end

    context 'when process has error' do
      class RunSickForest < RunForest
        private

        def call!
          raise StandardError, 'I eat ice cream'
        end
      end

      let(:process_class) { RunSickForest }

      describe '.call' do
        subject { process_instance.call }
        it_behaves_like 'processor error'
      end

      describe '.call!' do
        subject { process_instance.call! }
        it_behaves_like 'processor error'
      end

      describe '#call' do
        subject { process_class.call processed_object }
        it_behaves_like 'processor error'
      end

      describe '#call!' do
        subject { process_class.call! processed_object }
        it_behaves_like 'processor error'
      end
    end

    context 'when .call! method is undefined' do
      class LegasyForest < UseCases::Command
        def initialize(forest, distance: 1)
          @forest   = forest
          @distance = distance
        end
      end

      let(:process_class) { LegasyForest }

      describe '.call!' do
        subject(:call!) { process_instance.call! }

        it 'should raise `NotImplementedError`' do
          expect { call! }.to raise_error(Errors::AbstractMethod)
        end
      end
    end
  end
end
