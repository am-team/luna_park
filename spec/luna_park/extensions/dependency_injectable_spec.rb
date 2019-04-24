# frozen_string_literal: true

module ExtensionsDependencyInjectableSpec
  class Notifier; end

  class CreateTransaction
    include LunaPark::Extensions::DependencyInjectable

    dependency(:repository) { Hash[foo: 'FOO'] }
    dependency :today,      -> { Date.today }
    dependency :notifier,   Notifier, call: false

    def call
      [repository, today, notifier]
    end
  end
end

module LunaPark
  RSpec.describe Extensions::DependencyInjectable do
    let(:klass)    { ExtensionsDependencyInjectableSpec::CreateTransaction }
    let(:instance) { klass.new }

    let(:notifier_klass) { ExtensionsDependencyInjectableSpec::Notifier }

    context 'with default dependencies,' do
      it 'has expected dependencies' do
        expect(instance.dependencies.repository).to eq(foo: 'FOO')
        expect(instance.dependencies.today).to      eq Date.today
        expect(instance.dependencies.notifier).to   be notifier_klass
      end

      it 'accessible in instance' do
        expect(instance.call).to eq [{ foo: 'FOO' }, Date.today, notifier_klass]
      end

      it 'has private readers' do
        expect { instance.repository }.to raise_error NoMethodError, /\Aprivate method .+ called/
      end
    end

    context 'with substituted dependencies,' do
      let(:substituted) { double(repository: 'REPOSITORY', today: 'TODAY', notifier: 'NOTIFIER') }

      before { instance.dependencies = substituted }

      it 'has expected dependencies' do
        expect(instance.dependencies).to be substituted
      end

      it 'accessible in instance' do
        expect(instance.call).to eq %w[REPOSITORY TODAY NOTIFIER]
      end
    end
  end
end
