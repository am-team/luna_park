# frozen_string_literal: true

module ExtensionsComparableSpec
  Book = Struct.new(:title, :author, :weight) do
    include LunaPark::Extensions::Comparable

    comparable_attributes :title, :author
  end

  class ElectronicBook < Book; end
end

module LunaPark
  RSpec.describe Extensions::Comparable do
    let(:klass) { ExtensionsComparableSpec::Book }

    describe '#==' do
      subject(:eq) { left == right }

      let(:left)  { klass.new('Fahrenheit 451', 'Ray Douglas Bradbury') }
      let(:right) { klass.new('Fahrenheit 451', 'Ray Douglas Bradbury') }

      context 'when same registered properties,' do
        it { is_expected.to be true }

        context 'but different not registered property,' do
          let(:left)  { klass.new('Fahrenheit 451', 'Ray Douglas Bradbury', 666) }
          let(:right) { klass.new('Fahrenheit 451', 'Ray Douglas Bradbury', 42) }

          it { is_expected.to be true }
        end
      end

      context 'when different registered properties,' do
        let(:right) { klass.new('Dandelion Wine', 'Ray Douglas Bradbury') }

        it { is_expected.to be false }
      end

      context 'in inherited class behaves identically,' do
        let(:klass) { ExtensionsComparableSpec::ElectronicBook }

        context 'when same registered properties,' do
          it { is_expected.to be true }
        end

        context 'when different registered properties,' do
          let(:right) { klass.new('Dandelion Wine', 'Ray Douglas Bradbury') }

          it { is_expected.to be false }
        end
      end

      context 'when comparable_attributes is not registered' do
        # rubocop:disable Style/ClassAndModuleChildren, Style/StructInheritance
        let(:klass) do
          class ExtensionsComparableSpec::ClassName < Struct.new(:title, :author, :weight)
            include LunaPark::Extensions::Comparable
          end
        end
        # rubocop:enable Style/ClassAndModuleChildren, Style/StructInheritance

        it 'raises meaningfull exception' do
          expect { eq }.to raise_error Errors::NotConfigured,
                                       'You must set at least one comparable attribute ' \
                                       'using ExtensionsComparableSpec::ClassName.comparable_attributes(*names)'
        end
      end
    end

    describe '.debug' do
      subject(:debug) { klass.debug }
      let(:klass) { ExtensionsComparableSpec::Book.dup }

      it 'includes Extensions::ComparableDebug' do
        expect { debug }.to change { klass.include? Extensions::ComparableDebug }.from(false).to(true)
      end
    end

    describe '#debug' do
      subject(:debug) { klass.new.debug }
      let(:klass) { ExtensionsComparableSpec::Book.dup }

      it 'includes Extensions::ComparableDebug' do
        expect { debug }.to change { klass.include? Extensions::ComparableDebug }.from(false).to(true)
      end
    end
  end
end
