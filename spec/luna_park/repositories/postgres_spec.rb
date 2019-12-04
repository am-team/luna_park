# frozen_string_literal: true

require 'luna_park/repositories/postgres'

module LunaPark
  module Repositories
    RSpec.describe Postgres do
      let(:klass) { Class.new(described_class) }
      subject(:repo) { klass.new }

      describe '.mixins' do
        context 'when it is empty' do
          before { klass.mixins nil }

          it 'should not include any mixins' do
            is_expected.to_not be_a Extensions::Repositories::Postgres::Create
            is_expected.to_not be_a Extensions::Repositories::Postgres::Read
            is_expected.to_not be_a Extensions::Repositories::Postgres::Update
            is_expected.to_not be_a Extensions::Repositories::Postgres::Delete
          end
        end

        context 'when it is :create' do
          before { klass.mixins :create }

          it 'should include create mixins' do
            is_expected.to be_a Extensions::Repositories::Postgres::Create
          end
        end

        context 'when it is :read' do
          before { klass.mixins :read }

          it 'should include only read mixins' do
            is_expected.to be_a Extensions::Repositories::Postgres::Read
          end
        end

        context 'when it is :update' do
          before { klass.mixins :update }

          it 'should include only update mixins' do
            is_expected.to be_a Extensions::Repositories::Postgres::Update
          end
        end

        context 'when it is :delete' do
          before { klass.mixins :delete }

          it 'should include only read mixins' do
            is_expected.to be_a Extensions::Repositories::Postgres::Delete
          end
        end

        context 'when it is include multiple mixins' do
          before { klass.mixins(:create, :delete) }

          it 'should include only read mixins' do
            is_expected.to     be_a Extensions::Repositories::Postgres::Create
            is_expected.to_not be_a Extensions::Repositories::Postgres::Read
            is_expected.to_not be_a Extensions::Repositories::Postgres::Update
            is_expected.to     be_a Extensions::Repositories::Postgres::Delete
          end
        end
      end
    end
  end
end
