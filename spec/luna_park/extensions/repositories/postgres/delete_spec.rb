# frozen_string_literal: true

require 'securerandom'

RSpec.describe LunaPark::Extensions::Repositories::Postgres::Delete do
  let(:fake_repo_klass) do
    Class.new(LunaPark::Repositories::Sequel) do
      include LunaPark::Extensions::Repositories::Postgres::Delete

      attr_accessor :dataset

      primary_key :uid
    end
  end
  let(:fake_repo) { fake_repo_klass.new }

  describe '#delete' do
    subject(:delete) { fake_repo.delete(SecureRandom.uuid) }

    before { fake_repo.dataset = double }

    it 'returns received entity object' do
      expect(fake_repo.dataset).to receive_message_chain(:returning, :where, :delete)
      delete
    end
  end
end
