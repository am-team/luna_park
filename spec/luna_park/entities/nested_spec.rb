# frozen_string_literal: true

require 'ostruct'
require 'securerandom'

module Wrappable
  def wrap(input)
    case input
    when self then input
    when Hash then new(input)
    else raise ArgumentError
    end
  end
end

Eyes = Struct.new(:left, :right, keyword_init: true) { extend Wrappable }
Gun  = Struct.new(:title,        keyword_init: true) { extend Wrappable }

class Elephant < LunaPark::Entities::Nested
  namespace :head do
    attr :eyes, Eyes, :wrap
    attr :ears, OpenStruct, :new
    attr :trunk_length
  end

  attr :weapon, Gun, :wrap
  attr :height

  attr :number_of_crushed_enemies, comparable: false
  attr :last_battle_time,          comparable: false
end

module LunaPark
  RSpec.describe Entities::Nested do
    let(:klass)  { Elephant }
    let(:entity) { klass.new(params) }

    let(:params) do
      {
        head: {
          eyes: { left: 'Red', right: nil },
          ears: { left: 'Normal', right: 'Damaged' },
          trunk_length: 2.1
        },
        weapon: { title: 'BFG' },
        height: 4.2,
        number_of_crushed_enemies: 2328,
        last_battle_time: Date.parse('2018-12-07 06:40:09 UTC')
      }
    end

    describe '.new' do
      subject(:new) { klass.new(params) }

      it 'creates Entity' do
        expect(new).to be_a described_class
      end

      it 'creates with expected types' do
        expect(new.head.eyes).to                 be_a Eyes
        expect(new.head.ears).to                 be_a OpenStruct
        expect(new.head.trunk_length).to         be_a Float
        expect(new.weapon).to                    be_a Gun
        expect(new.number_of_crushed_enemies).to be_a Integer
        expect(new.last_battle_time).to          be_a Date
      end

      it 'creates with expected values structure' do
        expect(new.head.eyes.left).to            eq 'Red'
        expect(new.head.eyes.right).to           be nil
        expect(new.head.ears.left).to            eq 'Normal'
        expect(new.head.ears.right).to           eq 'Damaged'
        expect(new.head.trunk_length).to         eq 2.1
        expect(new.weapon.title).to              eq 'BFG'
        expect(new.number_of_crushed_enemies).to eq 2328
        expect(new.last_battle_time).to          eq Date.parse('2018-12-07 06:40:09 UTC')
      end
    end

    describe '.wrap' do
      subject(:wrap) { klass.wrap(input) }

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
          is_expected.to eq klass.new(params)
        end
      end

      context 'when given Not a mouse, not a frog, but an unknown creature' do
        let(:input) { params.to_a }

        it 'raises error with expected type' do
          expect { wrap }.to raise_error Errors::Unwrapable
        end

        it 'raises error with expected message' do
          expect { wrap }.to raise_error "Can`t wrap #{input.class}"
        end
      end
    end

    describe '#to_h' do
      subject(:to_h) { entity.to_h }

      let(:params) do
        {
          head: {
            eyes: { left: 'Red', right: nil },
            ears: { left: 'Normal', right: 'Damaged' },
            trunk_length: 2.1
          },
          weapon: { title: 'BFG' },
          height: [4.2, 3.5, 12],
          number_of_crushed_enemies: { swordmans: 1318, cavalery: 1010 },
          last_battle_time: Date.parse('2018-12-07 06:40:09 UTC')
        }
      end

      it 'returns same hash as given params' do
        is_expected.to eq params
      end

      context 'when entity was changed,' do
        before do
          entity.last_battle_time  = changed_time
          entity.head.trunk_length = changed_trunk
        end

        let(:changed_time)  { Date.parse('2018-12-07 00:00:00 UTC') }
        let(:changed_trunk) { 0.1 }

        let(:expected_hash) do
          hash = params.dup
          hash[:last_battle_time]    = changed_time
          hash[:head][:trunk_length] = changed_trunk
          hash
        end

        it 'returns expected hash' do
          is_expected.to eq expected_hash
        end
      end
    end

    describe '#== (controlled by `attr .., comparable: ..` option),' do
      subject(:equality) { entity == other }

      let(:other) { klass.new(other_params) }

      context 'when other created with the same params' do
        let(:other_params) { params }

        it { is_expected.to be true }
      end

      context 'when other created with different but uncomparable params' do
        let(:other_params) do
          params.merge(last_battle_time: Date.parse('2018-12-07 00:00:00 UTC'),
                       number_of_crushed_enemies: 2330)
        end

        it { is_expected.to be true }
      end

      context 'when other created with the different params' do
        let(:other_params) do
          o_params = params.dup
          o_params[:head][:ears][:left] = nil
          o_params
        end

        it { is_expected.to be false }
      end
    end

    describe '#inspect' do
      subject(:inspect) { entity.inspect }

      it 'returns expected string' do
        is_expected.to eq '#<Elephant ' \
          '@head=#<Namespace:head ' \
          '@eyes=#<struct Eyes left="Red", right=nil> ' \
          '@ears=#<OpenStruct left="Normal", right="Damaged"> ' \
          '@trunk_length=2.1> @weapon=#<struct Gun title="BFG"> ' \
          '@height=4.2 ' \
          '@number_of_crushed_enemies=2328 ' \
          '@last_battle_time=#<Date: 2018-12-07 ((2458460j,0s,0n),+0s,2299161j)>>'
      end
    end
  end
end
