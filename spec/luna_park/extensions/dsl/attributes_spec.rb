# frozen_string_literal: true

module ExtensionsAttributesSpec
  Ears = Struct.new(:left, :right, keyword_init: true)
  Enemy = Struct.new(:name)

  class CoerceEnemy
    def self.call(input)
      input.is_a?(Enemy) ? input : Enemy.new(input)
    end
  end

  class Elephant
    include LunaPark::Extensions::Comparable
    include LunaPark::Extensions::Serializable
    extend  LunaPark::Extensions::Dsl::Attributes

    attr :eyes_count
    attr :ears, Ears, :new
    attr :archenemy, CoerceEnemy
    attr :defeat_enemies, Enemy, :new, comparable: false, array: true
    attrs :a, :b, CoerceEnemy
    attr? :alive
    attrs? :active, :strong

    attr_accessor :smuggler

    def initialize(hash = {})
      @eyes_count = hash[:eyes_count]
      @ears = hash[:ears]
      @defeat_enemies = hash[:defeat_enemies]
      @alive = hash[:alive]
      @smuggler = hash[:smuggler]
      @active = hash[:active]
      @strong = hash[:strong]
    end
  end
end

module LunaPark
  RSpec.describe Extensions::Dsl::Attributes do
    let(:klass) { ExtensionsAttributesSpec::Elephant }
    let(:elephant) { klass.new }
    let(:e) { elephant }

    it 'sets .comparable_attributes for mixin LunaPark::Extensions::Serializable' do
      expect(klass.comparable_attributes_list).to match_array %i[eyes_count ears archenemy alive active strong a b]
    end

    it 'sets .serializable_attributes for mixin LunaPark::Extensions::Comparable' do
      expect(klass.serializable_attributes_list).to match_array %i[eyes_count ears defeat_enemies archenemy alive active strong a b]
    end

    describe 'defined by #attr?' do
      subject(:elephant) { klass.new(alive: true) }

      it 'creates predicate' do
        is_expected.to be_alive
      end
    end

    describe 'defined by #attrs?' do
      subject(:elephant) { klass.new(active: true, strong: false) }

      it 'creates predicates' do
        is_expected.to be_active
        is_expected.not_to be_strong
      end
    end

    describe 'defined by #attr' do
      context 'using attr(:name, Class, :method),' do
        let(:elephant) { klass.new(ears: { left: true, right: true }) }

        let(:ears_attrs) { { left: true, right: false } }
        let(:expected_ears) { ExtensionsAttributesSpec::Ears.new(ears_attrs) }

        it 'coerces value using `@name = Class.method(input)`' do
          expect { e.ears = ears_attrs }.to change { e.ears }.to(expected_ears)
        end
      end

      context 'using attr(:name, Class),' do
        let(:archenemy) { 'Mouse' }
        let(:expected_archenemy) { ExtensionsAttributesSpec::Enemy.new(archenemy) }

        it 'coerces value using `@name = Class.call(input)`' do
          expect { e.archenemy = archenemy }.to change { e.archenemy }.to(expected_archenemy)
        end
      end
    end

    describe 'defined by #attrs' do
      context 'without additional options,' do
        let(:enemy_names) { %w[Gnork Mork] }
        let(:expected_enemies) { enemy_names.map { |name| ExtensionsAttributesSpec::Enemy.new(name) } }

        it 'coerces each value using `@name = Class.method(input)`' do
          expect { e.defeat_enemies = enemy_names }.to change { e.defeat_enemies }.to(expected_enemies)
        end
      end

      context 'using attrs(*names, Class)' do
        let(:expected_c) { ExtensionsAttributesSpec::Enemy.new('a') }
        let(:expected_d) { ExtensionsAttributesSpec::Enemy.new('b') }

        it 'coerces input with Class.call' do
          expect { e.a = 'a' }.to change { e.a }.to(expected_c)
          expect { e.b = 'b' }.to change { e.b }.to(expected_d)
        end
      end
    end
  end
end
