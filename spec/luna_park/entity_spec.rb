# frozen_string_literal: true

require 'ostruct'
require 'securerandom'

module LunaPark
  RSpec.describe Entity do
    MyStruct = Struct.new(:foo) do
      def self.wrap(input)
        case input
        when self then input
        when Hash then new(input[:foo])
        else raise ArgumentError
        end
      end
    end

    let(:my_entity_klass) do
      Class.new(described_class) do
        namespace :my_namespace do
          attr :struct_a, MyStruct, :wrap
          attr :struct_b, OpenStruct, :new
          attr :simple
        end

        namespace :other_namespace do
          attr :not_comparable, comparable: false
        end

        attr :simple
        attr :not_comparable, comparable: false
      end
    end

    let(:entity) { my_entity_klass.new(params) }

    let(:params) do
      {
        my_namespace: {
          struct_a: { foo: 'Foo' },
          struct_b: { bar: 'Bar' },
          simple: 123
        },
        other_namespace: {
          not_comparable: '234'
        },
        simple: 21,
        not_comparable: 12
      }
    end

    describe '.new' do
      subject(:new) { my_entity_klass.new(params) }

      it 'creates Entity' do
        expect(new).to be_a described_class
      end

      it 'creates with expected types' do
        expect(new.my_namespace.struct_a).to          be_a MyStruct
        expect(new.my_namespace.struct_b).to          be_a OpenStruct
        expect(new.other_namespace.not_comparable).to be_a String
        expect(new.simple).to                         be_a Integer
        expect(new.not_comparable).to                 be_a Integer
      end

      it 'creates with expected values structure' do
        expect(new.my_namespace.struct_a.foo).to      eq 'Foo'
        expect(new.my_namespace.struct_b.bar).to      eq 'Bar'
        expect(new.my_namespace.simple).to            eq 123
        expect(new.other_namespace.not_comparable).to eq '234'
        expect(new.simple).to                         eq 21
        expect(new.not_comparable).to                 eq 12
      end
    end

    describe '.wrap' do
      subject(:wrap) { my_entity_klass.wrap(input) }

      context 'when given Entity' do
        let(:input) { entity }

        it 'returns Entity' do
          is_expected.to be_a described_class
        end

        it 'returns given entity' do
          is_expected.to be input
        end
      end

      context 'when given Hash' do
        let(:input) { params }

        it 'returns Entity' do
          is_expected.to be_a described_class
        end

        it 'returns Entity same as .new' do
          is_expected.to eq my_entity_klass.new(params)
        end
      end
    end

    describe '#to_h' do
      subject(:to_h) { entity.to_h }

      it 'returns same hash as given params' do
        is_expected.to eq params
      end

      context 'when entity was changed,' do
        before do
          entity.other_namespace.not_comparable = changed_a
          entity.simple = changed_b
        end

        let(:changed_a) { SecureRandom.hex }
        let(:changed_b) { rand(0..999_999) }

        let(:expected_hash) do
          hash = params.dup
          hash[:other_namespace][:not_comparable] = changed_a
          hash[:simple] = changed_b
          hash
        end

        it 'returns expected hash' do
          is_expected.to eq expected_hash
        end
      end
    end

    describe '#== (controlled by `attr .., comparable: ..` option),' do
      subject(:equality) { entity == other }

      let(:other) { my_entity_klass.new(other_params) }

      context 'when other creates from same params' do
        let(:other_params) { params }

        it { is_expected.to be true }
      end

      context 'when other creates from different uncomparable params' do
        let(:other_params) do
          o_params = params.dup
          o_params[:other_namespace][:not_comparable] = '999'
          o_params[:not_comparable] = 999
          o_params
        end

        it { is_expected.to be true }
      end

      context 'when other creates from different params' do
        let(:other_params) do
          o_params = params.dup
          o_params[:my_namespace][:simple] = 999
          o_params
        end

        it { is_expected.to be false }
      end
    end
  end
end