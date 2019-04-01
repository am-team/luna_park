# frozen_string_literal: true

module ExtensionsSerializableSpec
  class Book
    include LunaPark::Extensions::Serializable

    attr_accessor :title, :author, :comment, :in_sale

    protected(:in_sale) # rubocop:disable Style/AccessModifierDeclarations

    def in_sale?
      @in_sale
    end

    serializable_attributes :title, :author, :in_sale
  end

  class ElectronicBook < Book; end
end

module LunaPark
  RSpec.describe Extensions::Serializable do
    let(:klass)  { ExtensionsSerializableSpec::Book }
    let(:object) { klass.new }

    describe '#to_h' do
      subject(:to_h) { object.to_h }

      context 'when given none of registered properties,' do
        it 'returns empty Hash' do
          is_expected.to eq({})
        end
      end

      context 'when given all registered properties,' do
        let(:object) do
          klass.new.tap do |object|
            object.title  = 'Fahrenheit 451'
            object.author = 'Ray Douglas Bradbury'
            object.in_sale = true
          end
        end

        it 'returns Hash with all given properties' do
          is_expected.to eq(title: 'Fahrenheit 451', author: 'Ray Douglas Bradbury', in_sale: true)
        end
      end

      context 'when given some of registered properties,' do
        let(:object) do
          klass.new.tap do |object|
            object.title = 'Fahrenheit 451'
          end
        end

        it 'returns Hash with only given properties' do
          is_expected.to eq(title: 'Fahrenheit 451')
        end
      end

      context 'when given not registered property,' do
        let(:object) do
          klass.new.tap do |object|
            object.title   = 'Fahrenheit 451'
            object.comment = 'I like it!'
          end
        end

        it 'returns Hash with only given registered properties' do
          is_expected.to eq(title: 'Fahrenheit 451')
        end
      end

      context 'in inherited class,' do
        let(:klass) { ExtensionsSerializableSpec::ElectronicBook }
        let(:object) do
          klass.new.tap do |object|
            object.title  = 'Fahrenheit 451'
            object.author = 'Ray Douglas Bradbury'
          end
        end

        it 'behaves identically' do
          is_expected.to eq(title: 'Fahrenheit 451', author: 'Ray Douglas Bradbury')
        end
      end

      context 'when serializable_attributes is not registered' do
        # rubocop:disable Style/ClassAndModuleChildren, Style/StructInheritance
        let(:klass) do
          class ExtensionsSerializableSpec::ClassName < Struct.new(:title, :author, :weight)
            include LunaPark::Extensions::Serializable
          end
        end
        # rubocop:enable Style/ClassAndModuleChildren, Style/StructInheritance

        it 'raises meaningfull exception' do
          expect { to_h }.to raise_error Errors::NotConfigured,
                                         'You must set at least one serializable attribute ' \
                                         'using ExtensionsSerializableSpec::ClassName.serializable_attributes(*names)'
        end
      end
    end
  end
end
