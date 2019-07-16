# frozen_string_literal: true

require_relative '../../../lib/luna_park/extensions/data_mapper'

module ExtensionsDataMapperSpec
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

  class AccountRepository
    include LunaPark::Extensions::DataMapper

    mapper AccountMapper
    entity Account

    # when read_all receives Array of rows
    def all
      read_all accounts.values
    end

    # when read_one receives row
    def find(uid)
      read_one accounts[uid]
    end

    # when read_one receives Array of rows
    def get_one(_uid)
      read_one accounts.values
    end

    def create_one(input)
      entity = wrap input
      row = to_row entity
      accounts[entity.uid] ||= row
      entity
    end

    def create_many(input)
      entities = wrap_all input
      rows     = to_rows entities
      rows.each { |row| accounts[row[:id]] ||= row }
      entities
    end

    def seed!
      @dataset = {
        42 => { id: 42, account_type: 'Foo' },
        69 => { id: 69, account_type: 'Bar' }
      }
    end

    private

    def dataset
      @dataset ||= {}
    end

    alias accounts dataset
  end
end

module LunaPark
  RSpec.describe Extensions::DataMapper do
    subject(:repo) { ExtensionsDataMapperSpec::AccountRepository.new }

    context 'when dataset is empty' do
      it '#read_all returns empty array' do
        expect(repo.all).to eq []
      end

      it '#read_one returns nil when found nil' do
        expect(repo.find(42)).to be_nil
      end

      it '#read_one returns nil when found empty array' do
        expect(repo.find(42)).to be_nil
      end
    end

    context 'when dataset is full' do
      let(:expected_entities) do
        [ExtensionsDataMapperSpec::Account.new(uid: 42, type: 'Foo'),
         ExtensionsDataMapperSpec::Account.new(uid: 69, type: 'Bar')]
      end
      let(:new_entities) do
        [ExtensionsDataMapperSpec::Account.new(uid: 666, type: 'Baz'),
         ExtensionsDataMapperSpec::Account.new(uid: 777, type: 'Bat')]
      end
      let(:new_entity) { new_entities.first }

      before { repo.seed! }

      it '#to_entity, #from_row works fine' do
        expect(repo.find(42)).to eq expected_entities.first
      end

      it '#to_entity, #from_row returns nil when given nil' do
        expect(repo.find(0)).to be nil
      end

      it '#to_entities, #from_rows works fine' do
        expect(repo.all).to eq expected_entities
      end

      it '#wrap, #to_row returns expected value' do
        expect(repo.create_one(new_entity)).to eq new_entity
      end

      it '#wrap, #to_row works fine' do
        expect { repo.create_one(new_entity) }.to change { repo.find(new_entity.uid) }.from(nil).to(new_entity)
      end

      it '#wrap_all, #to_rows returns expected value' do
        expect(repo.create_many(new_entities)).to eq new_entities
      end

      it '#wrap, #to_row returns expected value' do
        expect { repo.create_many(new_entities) }.to change { repo.all }.from(expected_entities).to(expected_entities + new_entities)
      end
    end

    describe '#transaction' do
      let(:repo) do
        dataset_ = dataset
        klass = Class.new { include Extensions::DataMapper }
        klass.define_method(:dataset) { dataset_.new }
        klass
      end

      let(:dataset) do
        Struct.new(:_) do
          def transaction
            yield
          end
        end
      end

      it 'calls transaction of dataset' do
        expect_any_instance_of(dataset).to receive(:transaction)
        repo.new.transaction { 'some' }
      end

      it 'transaction returns block result' do
        expect(repo.new.transaction { 'RESULT' }).to eq 'RESULT'
      end
    end

    describe '#dataset' do
      subject(:dataset) { repo.new.send(:dataset) }
      let(:repo) { Class.new { include Extensions::DataMapper } }

      it 'raises NotImplementedError' do
        expect { dataset }.to raise_error(NotImplementedError)
      end
    end
  end
end
