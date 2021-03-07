# frozen_string_literal: true

require 'luna_park/extensions/repositories/postgres/update'
require 'luna_park/repository'
require 'luna_park/entities/attributable'

RSpec.describe LunaPark::Extensions::Repositories::Postgres::Update do
  let(:fake_repo_klass) do
    fake_entity_klass_ = fake_entity_klass

    Class.new(LunaPark::Repository) do
      include LunaPark::Extensions::Repositories::Postgres::Update

      attr_accessor :dataset

      entity fake_entity_klass_
      record_primary_key :uid

      def self.wrap(input)
        input
      end
    end
  end
  let(:fake_repo) { fake_repo_klass.new }

  let(:fake_entity_klass) do
    Class.new(LunaPark::Entities::Attributable) do
      attr :uid
      attr :updated_at
    end
  end
  let(:fake_entity) { fake_entity_klass.new }

  let(:time_now) { Time.now }

  let!(:fake_dataset) { fake_repo.dataset = double }

  describe '#save' do
    subject(:save) { fake_repo.save(fake_entity) }

    let(:fake_new_attrs) { { updated_at: time_now } }

    before do
      allow(fake_dataset).to receive_message_chain(:returning, :where, :update, :first).and_return(fake_new_attrs)
    end

    it 'returns received entity object' do
      expect(save).to be fake_entity
    end

    it 'changes entity updated_at' do
      expect { save }.to change { fake_entity.updated_at }.to time_now
    end
  end
end
