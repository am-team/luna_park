# frozen_string_literal: true

module RepositoriesSequelSpec
  Account = Struct.new(:uid, :type, keyword_init: true) do
    def self.wrap(input)
      return input if input.is_a?(self)

      new(input)
    end
  end

  class AccountMapper
    class << self
      def from_rows(rows)
        Array(rows).map { |row| from_row(row) }
      end

      def to_rows(attrs_)
        Array(attrs_).map { |attrs| to_row(attrs) }
      end

      def to_row(input)
        return if input.nil?

        attrs = input.to_h
        { id: attrs[:uid], account_type: attrs[:type] }
      end

      def from_row(row)
        return if row.nil?

        { uid: row[:id], type: row[:account_type] }
      end
    end
  end

  class AccountRepository < LunaPark::Repositories::Sequel
    mapper AccountMapper
    entity Account

    class << self
      def all
        to_entities from_rows store.values
      end

      def find(uid)
        to_entity from_row store[uid]
      end

      def create(input)
        input.is_a?(Array) ? create_many(input) : create_one(input)
      end

      def count
        store.count
      end

      def seed!
        @store = {
          42 => { id: 42, account_type: 'Foo' },
          69 => { id: 69, account_type: 'Bar' }
        }
      end

      private

      attr_reader :store

      def create_one(input)
        entity = wrap input
        row = to_row entity
        store[entity.uid] ||= row
        entity
      end

      def create_many(input)
        entities = wrap_all input
        rows     = to_rows entities
        rows.each { |row| store[row[:id]] ||= row }
        entities
      end
    end
  end
end

module LunaPark
  RSpec.describe Repositories::Sequel do
    subject(:repo) { RepositoriesSequelSpec::AccountRepository }

    let(:expected_entities) do
      [RepositoriesSequelSpec::Account.new(uid: 42, type: 'Foo'),
       RepositoriesSequelSpec::Account.new(uid: 69, type: 'Bar')]
    end
    let(:new_entities) do
      [RepositoriesSequelSpec::Account.new(uid: 666, type: 'Baz'),
       RepositoriesSequelSpec::Account.new(uid: 777, type: 'Bat')]
    end
    let(:new_entity) { new_entities.first }

    before { repo.seed! }

    it '.to_entity, .from_row works fine' do
      expect(repo.find(42)).to eq expected_entities.first
    end

    it '.to_entity, .from_row returns nil when given nil' do
      expect(repo.find(0)).to be nil
    end

    it '.to_entities, .from_rows works fine' do
      expect(repo.all).to eq expected_entities
    end

    it '.wrap, .to_row returns expected value' do
      expect(repo.create(new_entity)).to eq new_entity
    end

    it '.wrap, .to_row works fine' do
      expect { repo.create(new_entity) }.to change { repo.find(new_entity.uid) }.from(nil).to(new_entity)
    end

    it '.wrap_all, .to_rows returns expected value' do
      expect(repo.create(new_entities)).to eq new_entities
    end

    it '.wrap, .to_row returns expected value' do
      expect { repo.create(new_entities) }.to change { repo.all }.from(expected_entities).to(expected_entities + new_entities)
    end
  end
end
