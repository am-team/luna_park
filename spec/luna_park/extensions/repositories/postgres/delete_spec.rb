# frozen_string_literal: true

require 'securerandom'
require 'luna_park/extensions/repositories/postgres/delete'
require 'luna_park/repository'

RSpec.describe LunaPark::Extensions::Repositories::Postgres::Delete do
  let(:fake_repo_klass) do
    Class.new(LunaPark::Repository) do
      include LunaPark::Extensions::Repositories::Postgres::Delete

      attr_accessor :dataset

      primary_key :uid
      entity OpenStruct
    end
  end
  let(:fake_repo) { fake_repo_klass.new }
  let(:uuid) { SecureRandom.uuid }

  describe '#delete' do
    before do
      fake_repo.dataset = double
      allow(fake_repo.dataset).to receive_message_chain(:where, :delete).and_return 1
    end

    context 'when pk given' do
      subject(:delete) { fake_repo.delete(uuid) }

      it 'returns boolean' do
        expect(delete).to be true
      end

      it 'sends delete to db' do
        expect(fake_repo.dataset).to receive(:where).with(uid: uuid)
        delete
      end
    end

    context 'when expected entity given' do
      subject(:delete) { fake_repo.delete(fake_repo_klass.entity_class.new(uid: uuid)) }

      it 'sends delete to db' do
        expect(fake_repo.dataset).to receive(:where).with(uid: uuid)
        delete
      end
    end

    context 'when Hash given' do
      subject(:delete) { fake_repo.delete({ uid: uuid }) }

      it 'sends delete to db' do
        expect(fake_repo.dataset).to receive(:where).with(uid: uuid)
        delete
      end
    end

    context 'when extractable pk is nil' do
      subject(:delete) { fake_repo.delete({ uid: nil }) }

      it 'raises meaningfull error' do
        expect { delete }.to raise_error ArgumentError, "primary key 'uid' value can't be nil"
      end
    end

    context 'when pk is nil' do
      subject(:delete) { fake_repo.delete(nil) }

      it 'raises meaningfull error' do
        expect { delete }.to raise_error ArgumentError, "primary key 'uid' value can't be nil"
      end
    end

    context 'when any other type given' do
      subject(:delete) { fake_repo.delete(123) }

      it 'sends delete to db' do
        expect(fake_repo.dataset).to receive(:where).with(uid: 123)
        delete
      end
    end
  end
end
