# frozen_string_literal: true

require 'securerandom'

RSpec.describe LunaPark::Extensions::Repositories::Postgres::Create do
  let(:fake_repo_klass) do
    fake_entity_klass_ = fake_entity_klass

    Class.new(LunaPark::Repositories::Sequel) do
      include LunaPark::Extensions::Repositories::Postgres::Create

      attr_accessor :dataset

      entity fake_entity_klass_

      def self.wrap(input)
        input
      end
    end
  end
  let(:fake_repo) { fake_repo_klass.new }

  let(:fake_entity_klass) do
    Class.new(LunaPark::Entities::Attributable) do
      attr :uid
      attr :foo
      attr :bar
      attr :created_at
      attr :updated_at
    end
  end

  let(:fake_uid) { SecureRandom.uuid }
  let(:time_now) { Time.now }

  describe '#create' do
    subject(:create) { fake_repo.create(params) }

    let(:params)           { { uid: fake_uid, foo: 'FOO', bar: 'BAR' } }
    let(:fake_created_row) { params.merge(created_at: time_now, updated_at: time_now) }

    before do
      fake_repo.dataset = double
      allow(fake_repo.dataset).to receive_message_chain(:returning, :insert, :first).and_return(fake_created_row)
    end

    it 'returns entity' do
      expect(create).to be_a LunaPark::Entities::Attributable
    end

    it 'sets entity uid' do
      expect(create.uid).to eq fake_uid
    end

    it 'sets entity timestamps' do
      expect(create.updated_at).to eq time_now
      expect(create.created_at).to eq time_now
    end

    it 'sets entity attributes' do
      expect(create.foo).to eq params[:foo]
      expect(create.bar).to eq params[:bar]
    end
  end
end
