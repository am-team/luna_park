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
    end
  end
  let(:fake_repo) { fake_repo_klass.new }

  describe '#delete' do
    subject(:delete) { fake_repo.delete(SecureRandom.uuid) }

    before do
      fake_repo.dataset = double
      allow(fake_repo.dataset).to receive_message_chain(:where, :delete).and_return 1
    end

    it 'returns received entity object' do
      expect(fake_repo.dataset).to receive_message_chain(:where, :delete)
      delete
    end
  end
end
