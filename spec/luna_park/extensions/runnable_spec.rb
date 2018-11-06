module LunaPark
  RSpec.describe Extensions::Runnable do
    class ForestGump
      # in ft
      attr_accessor :distance_he_ran

      def initialize
        @distance_he_ran = 0
      end
    end

    class RunForest
      # TODO: Should be singleton ;)
      include Extensions::Runnable

      def initialize(forest, distance: 1)
        @forest   = forest
        @distance = distance
      end

      private

      attr_reader :forest, :distance

      def call!
        raise LunaPark::Errors::Processing, 'I have a day off'
      end
    end

    let(:processed_object) { ForestGump.new }
    let(:process_class)    { RunForest }
    let(:process_instance)         { process_class.new(processed_object) }

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

    describe '.run' do
      subject { process_instance.run }

      it { is_expected.to be true }
      it_behaves_like 'processor change object'
    end

    describe '.run!' do
      subject { process_instance.run! }

      it { is_expected.to be true }
      it_behaves_like 'processor change object'
    end

    describe '#run' do
      subject { process_class.run processed_object }

      it { is_expected.to be true }
      it_behaves_like 'processor change object'
    end

    describe '#run!' do
      subject { process_class.run! processed_object }

      it { is_expected.to be true }
      it_behaves_like 'processor change object'
    end

    it { expect(process_instance).to be_a Extensions::Runnable }

    context 'when process has fail' do
      class RunHolidayForest < RunForest
        private

        def call!
          raise Errors::Processing, 'I have a day off'
        end
      end

      let(:process_class) { RunHolidayForest }

      describe '.run' do
        subject(:run) { process_instance.run }

        it { is_expected.to be false }
        it { expect { run }.not_to raise_error }
        it_behaves_like 'processor does not change object'
      end

      describe '.run!' do
        subject { process_instance.run! }
        it_behaves_like 'processor fail'
      end

      describe '#run' do
        subject { process_class.run processed_object }

        it { is_expected.to be false }
        it_behaves_like 'processor does not change object'
      end

      describe '#run!' do
        subject { process_class.run! processed_object }
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

      describe '.run' do
        subject { process_instance.run }
        it_behaves_like 'processor error'
      end

      describe '.run!' do
        subject { process_instance.run! }
        it_behaves_like 'processor error'
      end

      describe '#run' do
        subject { process_class.run processed_object }
        it_behaves_like 'processor error'
      end

      describe '#run!' do
        subject { process_class.run! processed_object }
        it_behaves_like 'processor error'
      end
    end

    context 'when .call! method is undefined' do
      class LegasyForest
        include Extensions::Runnable

        def initialize(forest, distance: 1)
          @forest   = forest
          @distance = distance
        end
      end

      let(:process_class) { LegasyForest }

      describe '.run!' do
        subject(:run!) { process_instance.run! }

        it 'should raise `NotImplementedError`' do
          expect { run! }.to raise_error(NotImplementedError)
        end
      end
    end
  end
end
