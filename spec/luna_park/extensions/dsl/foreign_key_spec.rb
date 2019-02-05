# frozen_string_literal: true

module ExtensionsDslForeignKeySpec
  class Transaction
    include LunaPark::Extensions::Comparable
    include LunaPark::Extensions::Serializable
    extend  LunaPark::Extensions::Dsl::ForeignKey

    fk :user_uid, :user, pk: :uid # fk is foreign_key, pk is primary_key of target object
    fk :financier_id, :financier
  end

  User = Struct.new(:uid, :name, keyword_init: true)
  Financier = Struct.new(:id, keyword_init: true)
end

module LunaPark
  RSpec.describe Extensions::Dsl::ForeignKey do
    let(:transaction) { ExtensionsDslForeignKeySpec::Transaction.new }
    let(:user)        { ExtensionsDslForeignKeySpec::User.new(uid: 42) }
    let(:financier)   { ExtensionsDslForeignKeySpec::Financier.new(id: 69) }

    let(:t) { transaction }

    it 'sets .comparable_attributes for mixin LunaPark::Extensions::Serializable' do
      expect(t.class.comparable_attributes_list).to eq %i[user_uid financier_id]
    end

    it 'sets .serializable_attributes for mixin LunaPark::Extensions::Comparable' do
      expect(t.class.serializable_attributes_list).to eq %i[user_uid financier_id]
    end

    context 'when transaction has no user,' do
      it { expect(t.user).to     be nil }
      it { expect(t.user_uid).to be nil }

      it { expect { t.user = user }.to change { t.user_uid }.from(nil).to(user.uid) }
    end

    context 'when option `pk:` is not setted,' do
      it 'uses :id as default `pk:`' do
        expect { t.financier = financier }.to change { t.financier_id }.from(nil).to(financier.id)
      end
    end

    context 'when transaction has user,' do
      let(:transaction) { ExtensionsDslForeignKeySpec::Transaction.new.tap { |t| t.user = user } }
      let(:other_user)  { ExtensionsDslForeignKeySpec::User.new(uid: 666) }

      it { expect(t.user).to be user }
      it { expect(t.user_uid).to eq user.uid }

      it 'change user will change user_uid' do
        expect { t.user = other_user }.to change { t.user_uid }.from(user.uid).to(other_user.uid)
      end

      it 'remove user will remove user_uid' do
        expect { t.user = nil }.to change { t.user_uid }.from(user.uid).to(nil)
      end

      it 'remove user_uid will remove user' do
        expect { t.user_uid = nil }.to change { t.user }.from(user).to(nil)
      end

      it 'remove user_uid to missmatched uid will remove user' do
        expect { t.user_uid = 666 }.to change { t.user }.from(user).to(nil)
      end
    end
  end
end
