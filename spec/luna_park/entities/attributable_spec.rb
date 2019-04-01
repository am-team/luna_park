# frozen_string_literal: true

module EntitiesAttributableSpec
  class Example < LunaPark::Entities::Attributable
    attr :foo
    attr :bar, OpenStruct, :new
  end
end

module LunaPark
  RSpec.describe Entities::Attributable do
    let(:sample_klass) { EntitiesAttributableSpec::Example }

    it 'defines comparable attributes' do
      expect(sample_klass.comparable_attributes_list).to eq %i[foo bar]
    end

    it 'defines serializable attributes' do
      expect(sample_klass.serializable_attributes_list).to eq %i[foo bar]
    end

    it { expect(sample_klass).to respond_to :wrap } # TODO: normal spec for Wrappable
    it { expect(sample_klass).to respond_to :attr? } # TODO: normal spec for Dsl::attributes
  end
end
