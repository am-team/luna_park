# frozen_string_literal: true

require 'luna_park/extensions/attributable'

require 'luna_park/extensions/comparable'
require 'luna_park/extensions/serializable'

require 'luna_park/extensions/dsl/primary_key'

module ExtensionsDslPrimaryKeySpec
  class Initializable
    include LunaPark::Extensions::Attributable

    def initialize(**hash)
      set_attributes hash
    end
  end

  class TransactionA < Initializable
    include LunaPark::Extensions::Comparable
    include LunaPark::Extensions::Serializable
    extend  LunaPark::Extensions::Dsl::PrimaryKey

    attr_accessor :id
  end

  class TransactionParent < Initializable
    include LunaPark::Extensions::Comparable
    include LunaPark::Extensions::Serializable
    extend  LunaPark::Extensions::Dsl::PrimaryKey

    pk :uid
  end

  class TransactionChild < TransactionParent
    include LunaPark::Extensions::Comparable
    include LunaPark::Extensions::Serializable
    extend  LunaPark::Extensions::Dsl::PrimaryKey
  end
end

module LunaPark
  RSpec.xdescribe Extensions::Dsl::PrimaryKey do
    context 'when pk not described' do
      let(:t_class) { ExtensionsDslPrimaryKeySpec::TransactionA }
      let(:t)       { t_class.new(id: 42) }

      it 'not sets .comparable_attributes for mixin LunaPark::Extensions::Serializable' do
        expect(t.class.comparable_attributes_list).to be nil
      end

      it 'not sets .serializable_attributes for mixin LunaPark::Extensions::Comparable' do
        expect(t.class.serializable_attributes_list).to be_empty
      end

      describe '.pk, .primary_key' do
        it 'returns nil' do
          expect(t_class.pk).to be nil
        end

        it 'returns nil' do
          expect(t_class.primary_key).to be nil
        end
      end

      describe '#pk' do
        it 'returns pk value' do
          expect(t.pk).to be 42
        end

        it 'returns id' do
          expect(t.pk).to be t.id
        end
      end

      describe '#primary_key' do
        it 'returns primary_key value' do
          expect(t.primary_key).to be 42
        end

        it 'returns id' do
          expect(t.primary_key).to be t.id
        end
      end
    end

    context 'when pk described to :uid' do
      let(:t_class) { ExtensionsDslPrimaryKeySpec::TransactionParent }
      let(:t)       { t_class.new(uid: 42) }

      it 'sets .comparable_attributes for mixin LunaPark::Extensions::Serializable' do
        expect(t.class.comparable_attributes_list).to eq [:uid]
      end

      it 'sets .serializable_attributes for mixin LunaPark::Extensions::Comparable' do
        expect(t.class.serializable_attributes_list).to eq [:uid]
      end

      describe '.pk, .primary_key' do
        it 'returns nil' do
          expect(t_class.pk).to be :uid
        end

        it 'returns nil' do
          expect(t_class.primary_key).to be :uid
        end
      end

      describe '#pk' do
        it 'returns expected value' do
          expect(t.pk).to be 42
        end

        it 'returns id' do
          expect(t.pk).to be t.uid
        end
      end

      describe '#primary_key' do
        it 'returns expected value' do
          expect(t.primary_key).to be 42
        end

        it 'returns uid' do
          expect(t.primary_key).to be t.uid
        end
      end
    end

    context 'when pk described at parent' do
      let(:t_class) { ExtensionsDslPrimaryKeySpec::TransactionChild }
      let(:t)       { t_class.new(uid: 42) }

      it 'sets .comparable_attributes for mixin LunaPark::Extensions::Serializable' do
        expect(t.class.comparable_attributes_list).to eq [:uid]
      end

      it 'sets .serializable_attributes for mixin LunaPark::Extensions::Comparable' do
        expect(t.class.serializable_attributes_list).to eq [:uid]
      end

      describe '.pk, .primary_key' do
        it 'returns nil' do
          expect(t_class.pk).to be :uid
        end

        it 'returns nil' do
          expect(t_class.primary_key).to be :uid
        end
      end

      describe '#pk' do
        it 'returns expected value' do
          expect(t.pk).to be 42
        end

        it 'returns id' do
          expect(t.pk).to be t.uid
        end
      end

      describe '#primary_key' do
        it 'returns expected value' do
          expect(t.primary_key).to be 42
        end

        it 'returns uid' do
          expect(t.primary_key).to be t.uid
        end
      end
    end
  end
end
