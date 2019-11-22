# frozen_string_literal: true

require 'securerandom'

RSpec.describe LunaPark::Extensions::Repositories::Sequel::Read do
  let(:fake_repo_klass) do
    fake_entity_klass_ = fake_entity_klass

    Class.new(LunaPark::Repositories::Sequel) do
      include LunaPark::Extensions::Repositories::Sequel::Read

      attr_accessor :dataset

      entity fake_entity_klass_
      primary_key :uid

      def self.wrap(input)
        input
      end

      def self.name
        'Repositories::FakeEntity'
      end
    end
  end
  let(:fake_repo) { fake_repo_klass.new }

  let(:fake_entity_klass) do
    Class.new(LunaPark::Entities::Attributable) do
      attr :uid
      attr :foo
    end
  end

  let!(:fake_dataset) { fake_repo.dataset = double }

  let(:fake_uid) { SecureRandom.uuid }

  describe '#find' do
    subject(:find) { fake_repo.find(uid) }
    let(:uid) { 42 }

    context 'when exist' do
      let(:fake_row) { { uid: uid, foo: 'FOO' } }

      before { allow(fake_dataset).to receive(:where).with(uid: uid).and_return([fake_row]) }

      it { is_expected.to eq fake_entity_klass.new(fake_row) }
    end

    context 'when not exist' do
      before { allow(fake_dataset).to receive(:where).with(uid: uid).and_return([]) }

      it { is_expected.to be_nil }
    end
  end

  describe '#find!' do
    subject(:find!) { fake_repo.find!(uid) }
    let(:uid) { 42 }

    context 'when exist' do
      let(:fake_row) { { uid: uid, foo: 'FOO' } }

      before { allow(fake_dataset).to receive(:where).with(uid: uid).and_return([fake_row]) }

      it { is_expected.to eq fake_entity_klass.new(fake_row) }
    end

    context 'when not exist' do
      before { allow(fake_dataset).to receive(:where).with(uid: uid).and_return([]) }

      it { expect { find! }.to raise_error LunaPark::Errors::NotFound, 'FakeEntity (42)' }
    end
  end

  describe '#lock' do
    subject(:lock) { fake_repo.lock(uid) }
    let(:uid) { 42 }

    context 'when exist' do
      before do
        allow(fake_dataset).to receive_message_chain(:for_update, :select, :where).and_return(['some result'])
      end

      it { is_expected.to be true }
    end

    context 'when not exist' do
      before do
        allow(fake_dataset).to receive_message_chain(:for_update, :select, :where).and_return([])
      end

      it { is_expected.to be false }
    end
  end

  describe '#lock!' do
    subject(:lock!) { fake_repo.lock!(uid) }
    let(:uid) { 42 }

    context 'when exist' do
      before do
        allow(fake_dataset).to receive_message_chain(:for_update, :select, :where).and_return(['some result'])
      end

      it { is_expected.to be true }
    end

    context 'when not exist' do
      before do
        allow(fake_dataset).to receive_message_chain(:for_update, :select, :where).and_return([])
      end

      it { expect { lock! }.to raise_error LunaPark::Errors::NotFound, 'FakeEntity (42)' }
    end
  end

  describe '#count' do
    subject(:count) { fake_repo.count }

    before do
      allow(fake_dataset).to receive(:count).and_return(69)
    end

    it { is_expected.to eq 69 }
  end

  describe '#all' do
    subject(:all) { fake_repo.all }

    before do
      allow(fake_dataset).to receive(:order).and_return double(to_a: [{ uid: 42, foo: 'Foo' }, { uid: 777, foo: 'Bar' }])
    end

    it { is_expected.to eq [fake_entity_klass.new(uid: 42, foo: 'Foo'), fake_entity_klass.new(uid: 777, foo: 'Bar')] }
  end

  describe '#last' do
    subject(:last) { fake_repo.last }

    before do
      allow(fake_dataset).to receive_message_chain(:order, :last).and_return(uid: 777, foo: 'Bar')
    end

    it { is_expected.to eq fake_entity_klass.new(uid: 777, foo: 'Bar') }
  end
end
