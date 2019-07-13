# frozen_string_literal: true

module HasPrimaryKeySpec
  class Example
    extend LunaPark::Extensions::Dsl::HasPrimaryKey

    primary_key :uid

    def initialize(attrs)
      attrs.each_pair { |k, v| send(:"#{k}=", v) }
    end
  end

  class ExampleWithDsl
    extend LunaPark::Extensions::Dsl::HasPrimaryKey
    extend LunaPark::Extensions::Dsl::Attributes
    include LunaPark::Extensions::Comparable
    include LunaPark::Extensions::Serializable

    primary_key :uid

    def initialize(attrs)
      attrs.each_pair { |k, v| send(:"#{k}=", v) }
    end
  end
end

module LunaPark
  RSpec.describe Extensions::Dsl::HasPrimaryKey do
    let(:instance) { klass.new(uid: 42) }

    context 'without other extensions' do
      let(:klass) { HasPrimaryKeySpec::Example }

      it { expect(instance.uid).to                     eq 42 }
      it { expect(instance.primary_key).to             eq 42 }
      it { expect(klass.wrap_primary_key(42)).to       eq 42 }
      it { expect(klass.wrap_primary_key(instance)).to eq 42 }
    end

    context 'with Dsl::Attributes' do
      let(:klass) { HasPrimaryKeySpec::ExampleWithDsl }

      it { expect(instance.uid).to                     eq 42 }
      it { expect(instance.primary_key).to             eq 42 }
      it { expect(klass.wrap_primary_key(42)).to       eq 42 }
      it { expect(klass.wrap_primary_key(instance)).to eq 42 }
      it { expect(instance.to_h).to                    eq(uid: 42) }
      it { expect(instance).not_to                     eq klass.new(uid: 1) }
      it { expect(instance).to                         eq klass.new(uid: 42) }
      it { expect(klass.comparable_attributes_list).to   eq [:uid] }
      it { expect(klass.serializable_attributes_list).to eq [:uid] }
    end
  end
end
