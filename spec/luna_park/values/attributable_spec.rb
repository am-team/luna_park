# frozen_string_literal: true

module ValuesAttributableSpec
  class Money < LunaPark::Values::Attributable
    attr :currency, OpenStruct, :new
    attr :fractional
  end
end

module LunaPark
  RSpec.describe Values::Attributable do
    let(:sample_klass) { ValuesAttributableSpec::Money }

    it 'defines comparable attributes' do
      expect(sample_klass.comparable_attributes_list).to eq %i[currency fractional]
    end

    it 'defines serializable attributes' do
      expect(sample_klass.serializable_attributes_list).to eq %i[currency fractional]
    end

    it { expect(sample_klass).to respond_to :wrap } # TODO: normal spec for Wrappable
    it { expect(sample_klass).to respond_to :attr? } # TODO: normal spec for Dsl::attributes

    it 'setters becomes protected' do
      expect { sample_klass.new.currency = 'RUB' }.to raise_error NoMethodError, /\Aprotected method `currency=' called/
    end
  end
end
