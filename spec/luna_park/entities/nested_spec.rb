# frozen_string_literal: true

require 'ostruct'
require 'securerandom'

Eyes = Struct.new(:left, :right, keyword_init: true) { extend LunaPark::Extensions::Wrappable }
Gun  = Struct.new(:title,        keyword_init: true) { extend LunaPark::Extensions::Wrappable }

class Elephant < LunaPark::Entities::Nested
  namespace :head do
    attr  :eyes, Eyes, :wrap
    attrs :ears, :legs, OpenStruct, :new
    attr  :trunk_length
  end

  attr? :alive
  attr  :weapon, Gun, :wrap
  attr  :height

  attrs :number_of_crushed_enemies, :last_battle_time, comparable: false
end

module LunaPark
  RSpec.describe Entities::Nested do
    let(:sample_class) { Elephant }
    let(:entity)       { sample_class.new(params) }

    let(:params) do
      {
        head: {
          eyes: { left: 'Red', right: nil },
          ears: { left: 'Normal', right: 'Damaged' },
          legs: { lb: true, rb: true, lf: true, rf: true },
          trunk_length: 2.1
        },
        alive: true,
        weapon: { title: 'BFG' },
        height: 4.2,
        number_of_crushed_enemies: 2328,
        last_battle_time: Date.parse('2018-12-07 06:40:09 UTC')
      }
    end

    describe '.new' do
      subject(:new) { sample_class.new(params) }

      it 'creates Entity' do
        expect(new).to be_a described_class
      end

      it 'creates with expected types' do
        expect(new.head.eyes).to                 be_a Eyes
        expect(new.head.ears).to                 be_a OpenStruct
        expect(new.head.trunk_length).to         be_a Float
        expect(new.weapon).to                    be_a Gun
        expect(new.alive?).to                    be_a TrueClass
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
        expect(new.alive?).to                    be true
        expect(new.number_of_crushed_enemies).to eq 2328
        expect(new.last_battle_time).to          eq Date.parse('2018-12-07 06:40:09 UTC')
      end
    end

    describe '.wrap' do
      subject(:wrap) { sample_class.wrap(input) }

      let(:object)    { entity }
      let(:arguments) { params }

      include_examples 'wrap method'

      context 'when given Hash,' do
        let(:input) { arguments }

        it 'returns self type' do
          is_expected.to be_a described_class
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
      let(:other) { sample_class.new(other_params) }

      context 'when other created with the same params,' do
        let(:other_params) { params }

        it { expect(entity).to eq other }
      end

      context 'when other created with different but uncomparable params,' do
        let(:other_params) do
          params.merge(last_battle_time: Date.parse('2018-12-07 00:00:00 UTC'),
                       number_of_crushed_enemies: 2330)
        end

        it { expect(entity).to eq other }
      end

      context 'when other created with the different params,' do
        let(:other_params) do
          o_params = params.dup
          o_params[:head][:ears][:left] = nil
          o_params
        end

        it { expect(entity).not_to eq other }
      end
    end

    describe '#inspect' do
      subject(:inspect) { entity.inspect }

      it 'returns expected string' do
        is_expected.to eq '#<Elephant ' \
          'head=#<Namespace:head ' \
          'eyes=#<struct Eyes left="Red", right=nil> ' \
          'ears=#<OpenStruct left="Normal", right="Damaged"> ' \
          'legs=#<OpenStruct lb=true, rb=true, lf=true, rf=true> ' \
          'trunk_length=2.1> alive=true ' \
          'weapon=#<struct Gun title="BFG"> height=4.2 ' \
          'number_of_crushed_enemies=2328 ' \
          'last_battle_time=#<Date: 2018-12-07 ((2458460j,0s,0n),+0s,2299161j)>>'
      end
    end
  end
end
