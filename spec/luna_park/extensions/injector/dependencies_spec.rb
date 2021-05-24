# frozen_string_literal: true

require 'luna_park/extensions/injector/dependencies'

module LunaPark
  RSpec.describe Extensions::Injector::Dependencies do
    describe '.try_convert' do
      subject(:converted_result) { described_class.try_convert data }

      context 'when try convert hash' do
        let(:data) { { a: 1 } }

        it { is_expected.to be_a_kind_of described_class }
      end

      context 'when try convert unhashible class' do
        let(:data) { 'string' }

        it { is_expected.to be_nil }
      end
    end

    describe '#run' do
      let(:result) { double call: :result }
      let(:dependencies) { described_class.try_convert(foo: -> { result.call }) }

      subject(:run_dependency) { dependencies.call_with_cache(:foo) }

      it 'should return call result' do
        is_expected.to eq :result
      end

      it 'should call method once (memorized result)' do
        expect(result).to receive(:call).once

        run_dependency
        run_dependency
      end

      context 'when run undefined dependency' do
        subject(:run_dependency) { dependencies.call_with_cache(:undefined) }

        it { expect { run_dependency }.to raise_error KeyError, 'key not found: :undefined' }
      end

      context 'when defined dependency not callable instance' do
        let(:dependencies) { described_class.try_convert(foo: 1) }

        it { expect { run_dependency }.to raise_error NoMethodError, "undefined method `call' for 1:Integer" }
      end
    end

    describe '#[]=' do
      let(:result)         { double }
      let(:dependencies)   { described_class.try_convert(foo: -> { nil }) }
      let(:run_dependency) { dependencies.call_with_cache(:foo) }

      it 'should reset memorization' do
        expect { dependencies[:foo] = -> { result } }.to change {
          dependencies.call_with_cache(:foo)
        }.from(nil).to(result)
      end
    end
  end
end
