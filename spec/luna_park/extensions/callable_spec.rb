module LunaPark
  RSpec.describe Extensions::Callable do
    class Cthulhu
      # TODO: Should be singleton ;)
      include Extensions::Callable

      FHTAGN = "Ph'nglui mglw'nafh Cthulhu R'lyeh wgah'nagl fhtagn"

      def call!
        FHTAGN
      end
    end

    let(:callable_class) { Cthulhu }
    let(:call_result)    { Cthulhu::FHTAGN }
    let(:object)         { callable_class.new }

    it { expect(object).to be_a callable_class }

    shared_examples 'success call' do
      it 'should return `object.call` result' do
        is_expected.to eq call_result
      end
    end

    describe '.call' do
      subject { object.call }

      it_behaves_like 'success call'
    end

    describe '.call!' do
      subject { object.call! }

      it_behaves_like 'success call'
    end

    describe '#call' do
      subject { callable_class.call }

      it 'should return `object.call` result' do
        is_expected.to eq call_result
      end
    end

    describe '#call!' do
      subject { callable_class.call! }

      it 'should return `object.call` result' do
        is_expected.to eq call_result
      end
    end

    context 'when `object.call` method return `Processing` error ' do
      class CthulhuAtHoliday
        include Extensions::Callable

        def call!
          raise Errors::Processing, 'I have a day off'
        end
      end

      let(:processing_error) { Errors::Processing }
      let(:callable_class)   { CthulhuAtHoliday }

      describe '.call' do
        subject(:call) { callable_class.new.call }

        it { expect { call }.not_to raise_error }
        it { is_expected.to be_nil }
      end

      describe '.call!' do
        subject(:call!) { object.call! }

        it 'should raise `Errors::Processing`' do
          expect { call! }.to raise_error(processing_error)
        end
      end

      describe '#call' do
        subject(:call) { callable_class.call }

        it { expect { call }.not_to raise_error }
        it { is_expected.to be_nil }
      end

      describe '#call!' do
        subject(:call!) { callable_class.call! }

        it 'should raise `Errors::Processing`' do
          expect { call! }.to raise_error(processing_error)
        end
      end
    end

    context 'when `object.call` method return `StandardError` error ' do
      class CthulhuSick
        include Extensions::Callable

        def call!
          raise StandardError, 'I am on sick leave'
        end
      end

      let(:standard_error) { StandardError }
      let(:callable_class) { CthulhuSick }

      describe '.call' do
        subject { callable_class.new.call }

        it 'should raise `StandardError`' do
          expect { subject }.to raise_error(standard_error)
        end
      end

      describe '.call!' do
        subject { object.call! }

        it 'should raise `StandardError`' do
          expect { subject }.to raise_error(standard_error)
        end
      end

      describe '#call' do
        subject { callable_class.call }

        it 'should raise `StandardError`' do
          expect { subject }.to raise_error(standard_error)
        end
      end

      describe '#call!' do
        subject { callable_class.call! }

        it 'should raise `StandardError`' do
          expect { subject }.to raise_error(standard_error)
        end
      end
    end

    context 'when .call! method is undefined' do
      class LegasyCthulhu
        include Extensions::Callable
      end

      let(:callable_class) { LegasyCthulhu }

      describe '.call!' do
        subject { object.call! }

        it 'should raise `NotImplementedError`' do
          expect { subject }.to raise_error(NotImplementedError)
        end
      end
    end
  end
end