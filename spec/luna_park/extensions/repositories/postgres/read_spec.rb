# frozen_string_literal: true

require 'securerandom'
require 'luna_park/extensions/repositories/postgres/read'
require 'luna_park/repository'
require 'luna_park/entities/attributable'

RSpec.describe LunaPark::Extensions::Repositories::Postgres::Read do
  class MyEntity < LunaPark::Entities::Attributable
    attr :uid
    attr :value
  end

  class MyRepository < LunaPark::Repository
    include LunaPark::Extensions::Repositories::Postgres::Read

    attr_accessor :dataset

    entity MyEntity
    primary_key :uid

    def self.wrap(input)
      input
    end
  end

  let(:repo)          { MyRepository.new }
  let!(:fake_dataset) { repo.dataset = double }

  describe '#find' do
    subject(:find) { repo.find(uid) }
    let(:uid) { 42 }

    context 'when exist' do
      let(:fake_row) { { uid: uid, value: 'FOO' } }

      before { allow(fake_dataset).to receive(:where).with(uid: uid).and_return([fake_row]) }

      it { is_expected.to eq MyEntity.new(fake_row) }
    end

    context 'when not exist' do
      before { allow(fake_dataset).to receive(:where).with(uid: uid).and_return([]) }

      it { is_expected.to be_nil }
    end
  end

  describe '#reload!' do
    subject(:reload) { repo.reload!(fake_entity) }

    let(:uid) { 42 }
    let(:fake_entity) { MyEntity.new(uid: uid, value: 'FOO') }

    context 'when exist' do
      before { allow(fake_dataset).to receive(:where).with(uid: uid).and_return([uid: uid, value: 'BAR']) }

      it { is_expected.to be fake_entity }
      it { expect { reload }.to change(fake_entity, :value).from('FOO').to('BAR') }
    end

    context 'when gone' do
      before { allow(fake_dataset).to receive(:where).with(uid: uid).and_return([]) }

      it { expect { reload }.to raise_error MyRepository::NotFound, 'MyEntity ({:uid=>42})' }
    end
  end

  describe '#find!' do
    subject(:find!) { repo.find!(uid) }
    let(:uid) { 42 }

    context 'when exist' do
      let(:fake_row) { { uid: uid, value: 'FOO' } }

      before { allow(fake_dataset).to receive(:where).with(uid: uid).and_return([fake_row]) }

      it { is_expected.to eq MyEntity.new(fake_row) }
    end

    context 'when not exist' do
      before { allow(fake_dataset).to receive(:where).and_return([]) }

      it { expect { find! }.to raise_error MyRepository::NotFound, 'MyEntity (42)' }
    end
  end

  describe '#count' do
    subject(:count) { repo.count }

    before do
      allow(fake_dataset).to receive(:count).and_return(69)
    end

    it { is_expected.to eq 69 }
  end

  describe '#all' do
    subject(:all) { repo.all }

    before do
      allow(fake_dataset).to receive(:order).and_return double(to_a: [{ uid: 42, value: 'Foo' }, { uid: 777, value: 'Bar' }])
    end

    it { is_expected.to eq [MyEntity.new(uid: 42, value: 'Foo'), MyEntity.new(uid: 777, value: 'Bar')] }
  end

  describe '#last' do
    subject(:last) { repo.last }

    before do
      allow(fake_dataset).to receive_message_chain(:order, :last).and_return(uid: 777, value: 'Bar')
    end

    it { is_expected.to eq MyEntity.new(uid: 777, value: 'Bar') }
  end
end
