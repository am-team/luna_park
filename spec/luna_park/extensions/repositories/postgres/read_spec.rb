# frozen_string_literal: true

require 'securerandom'
require 'luna_park/extensions/repositories/postgres/read'
require 'luna_park/repository'
require 'luna_park/entities/attributable'

RSpec.describe LunaPark::Extensions::Repositories::Postgres::Read do
  class MyEntity < LunaPark::Entities::Attributable
    attr :uid
    attr :foo
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
      let(:fake_row) { { uid: uid, foo: 'FOO' } }

      before { allow(fake_dataset).to receive(:where).with(uid: uid).and_return([fake_row]) }

      it { is_expected.to eq MyEntity.new(fake_row) }
    end

    context 'when not exist' do
      before { allow(fake_dataset).to receive(:where).with(uid: uid).and_return([]) }

      it { is_expected.to be_nil }
    end
  end

  describe '#find!' do
    subject(:find!) { repo.find!(uid) }
    let(:uid) { 42 }

    context 'when exist' do
      let(:fake_row) { { uid: uid, foo: 'FOO' } }

      before { allow(fake_dataset).to receive(:where).with(uid: uid).and_return([fake_row]) }

      it { is_expected.to eq MyEntity.new(fake_row) }
    end

    context 'when not exist' do
      before { allow(fake_dataset).to receive(:where).with(uid: uid).and_return([]) }

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
      allow(fake_dataset).to receive(:order).and_return double(to_a: [{ uid: 42, foo: 'Foo' }, { uid: 777, foo: 'Bar' }])
    end

    it { is_expected.to eq [MyEntity.new(uid: 42, foo: 'Foo'), MyEntity.new(uid: 777, foo: 'Bar')] }
  end

  describe '#last' do
    subject(:last) { repo.last }

    before do
      allow(fake_dataset).to receive_message_chain(:order, :last).and_return(uid: 777, foo: 'Bar')
    end

    it { is_expected.to eq MyEntity.new(uid: 777, foo: 'Bar') }
  end
end
