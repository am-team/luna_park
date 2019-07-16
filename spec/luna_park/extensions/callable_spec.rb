# frozen_string_literal: true

require_relative '../../../lib/luna_park/extensions/callable'

class SaulGoodman
  extend LunaPark::Extensions::Callable

  def call
    "Saul's always looking out for your best interests."
  end

  def call!
    "Don't drink and drive. But if you do, call me."
  end
end

module LunaPark
  RSpec.describe Extensions::Callable do
    let(:klass) { SaulGoodman }
    let(:obj)   { klass.new }

    describe '#call' do
      subject { klass.call }
      it 'should eq instance call' do
        is_expected.to eq obj.call
      end
    end

    describe '#call!' do
      subject { klass.call! }
      it 'should eq instance call' do
        is_expected.to eq obj.call!
      end
    end
  end
end
