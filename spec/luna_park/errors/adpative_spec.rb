# frozen_string_literal: true

require 'i18n'
I18n.load_path << Dir['spec/locales/*.yml']

require 'luna_park/errors/adaptive'

module LunaPark
  RSpec.describe Errors::Adaptive do
    describe '#initialize' do
      context 'when use undefined action value' do
        it { expect { described_class.new action: :undefined }.to raise_error ArgumentError }
      end

      context 'when use undefined notify value' do
        it { expect { described_class.new notify: :undefined }.to raise_error ArgumentError }
      end
    end

    describe '#action' do
      subject(:action) { error.action }
      context 'action is undefined' do
        let(:error) { described_class.new }

        it { is_expected.to eq :raise }
      end

      context 'action defined in class' do
        let(:error_class) do
          Class.new(described_class) do
            on_error action: :catch
          end
        end
        let(:error) { error_class.new }

        it { is_expected.to eq :catch }
      end

      context 'action defined in class' do
        let(:error) { described_class.new(action: :stop) }

        it { is_expected.to eq :stop }
      end
    end

    describe '#notify?' do
      subject(:notify?) { error.notify? }

      context 'notify is undefined' do
        let(:error) { described_class.new }

        it { is_expected.to eq false }
      end

      context 'action defined in class' do
        let(:error_class) do
          Class.new(described_class) do
            on_error notify: true
          end
        end
        let(:error) { error_class.new }

        it { is_expected.to eq true }
      end

      context 'action defined in class' do
        let(:error) { described_class.new(notify: :info) }

        it { is_expected.to eq true }
      end
    end

    describe '#notify_lvl' do
      subject(:notify_lvl) { error.notify_lvl }

      context 'notify is undefined' do
        let(:error) { described_class.new }

        it { is_expected.to eq :error }
      end

      context 'action defined in class' do
        let(:error_class) do
          Class.new(described_class) do
            on_error notify: :info
          end
        end
        let(:error) { error_class.new }

        it { is_expected.to eq :info }
      end

      context 'action defined in class' do
        let(:error) { described_class.new(notify: :warning) }

        it { is_expected.to eq :warning }
      end
    end

    describe '#message' do
      context 'message is not defined' do
        subject(:message) { described_class.new.message }

        it 'should be eq class name' do
          is_expected.to eq described_class.name
        end
      end

      context 'message is defined on initialization error object' do
        let(:msg) { 'defined message' }
        subject(:message) { described_class.new(msg).message }

        it 'should be eq class name' do
          is_expected.to eq msg
        end
      end

      context 'message defined in class' do
        let(:error) do
          Class.new(described_class) do
            message 'Class message'
          end
        end

        context 'message is not defined on initialization error object' do
          subject(:message) { error.new.message }

          it 'should be eq class name' do
            is_expected.to eq 'Class message'
          end
        end

        context 'message is defined on initialization error object' do
          let(:msg) { 'defined message' }
          subject(:message) { error.new(msg).message }

          it 'should be eq class name' do
            is_expected.to eq msg
          end
        end
      end
    end

    describe '#details' do
      subject(:details) { error.details }

      context 'when details is undefined' do
        let(:error) { described_class.new }

        it { is_expected.to eq({}) }
      end

      context 'when details is defined' do
        let(:error) { described_class.new('Error message', answer: 42, foo: :bar) }

        it { is_expected.to eq(answer: 42, foo: :bar) }
      end
    end

    describe '.default_notify' do
      subject(:default_notify) { error_class.default_notify }

      context 'when default notify is not defined' do
        let(:error_class) { described_class }

        it 'is eq error class name' do
          is_expected.to eq nil
        end
      end

      context 'when default message is defined' do
        let(:error_class) do
          Class.new(described_class) do
            on_error action: :raise, notify: :error
          end
        end

        it 'is eq defined level' do
          is_expected.to eq :error
        end
      end
    end

    describe '.i18n_key' do
      subject(:i18n_key) { error_class.i18n_key }

      context 'when i18n key is not defined' do
        let(:error_class) { described_class }

        it { is_expected.to eq nil }
      end

      context 'when i18n key is defined' do
        let(:error_class) do
          Class.new(described_class) do
            message i18n_key: 'errors.example'
          end
        end

        it 'is eq defined key' do
          is_expected.to eq 'errors.example'
        end
      end
    end

    describe '.on_error' do
      let(:error_class) do
        Class.new(described_class) do
          on_error action: :catch, notify: :info
        end
      end

      it 'define default action' do
        expect(error_class.default_action).to eq :catch
      end

      it 'define notify behaviour' do
        expect(error_class.default_notify).to eq :info
      end

      context 'when use undefined action value' do
        let(:error_class) do
          Class.new(described_class) do
            on_error action: :undefined, notify: :info
          end
        end

        it { expect { error_class }.to raise_error ArgumentError }
      end

      context 'when use undefined action value' do
        let(:error_class) do
          Class.new(described_class) do
            on_error action: :undefined, notify: :info
          end
        end

        it { expect { error_class }.to raise_error ArgumentError }
      end
    end

    describe '.message' do
      let(:error_class) do
        Class.new(described_class) do
          message 'Text', i18n_key: 'errors.example_key'
        end
      end

      it 'define default action' do
        expect(error_class.default_message).to eq 'Text'
      end

      it 'define 118n_key' do
        expect(error_class.i18n_key).to eq 'errors.example_key'
      end

      context 'when use undefined action value' do
        let(:error_class) do
          Class.new(described_class) do
            on_error action: :undefined, notify: :info
          end
        end

        it { expect { error_class }.to raise_error ArgumentError }
      end

      context 'when use undefined action value' do
        let(:error_class) do
          Class.new(described_class) do
            on_error action: :undefined, notify: :info
          end
        end

        it { expect { error_class }.to raise_error ArgumentError }
      end
    end

    describe '.default_message' do
      subject(:default_message) { error_class.default_message }

      context 'when default message is not defined' do
        let(:error_class) { described_class }

        it 'is eq error class name' do
          is_expected.to eq error_class.name
        end
      end

      context 'when default message is defined' do
        let(:error_class) do
          Class.new(described_class) do
            message 'Defined message'
          end
        end

        it 'is eq defined message' do
          is_expected.to eq 'Defined message'
        end
      end

      context 'when i18n key is defined' do
        let(:error_class) do
          Class.new(described_class) do
            message i18n_key: 'errors.example'
          end
        end

        it 'is eq error class name' do
          is_expected.to eq error_class.name
        end
      end
    end

    describe '.translate' do
      subject(:translate) { error_class.translate }

      context 'when i18n key is not defined' do
        let(:error_class) { described_class }

        it { is_expected.to eq nil }
      end

      context 'when i18n_key is defined' do
        let(:error_class) do
          Class.new(described_class) do
            message i18n_key: 'errors.example'
          end
        end

        it 'is eq translation of default locale' do
          is_expected.to eq 'Example'
        end
      end

      context 'when i18n_key is defined and selected locale' do
        subject(:translate) { error_class.translate locale: :ru }

        let(:error_class) do
          Class.new(described_class) do
            message i18n_key: 'errors.example'
          end
        end

        it 'is eq  translation of selected locale' do
          is_expected.to eq 'Пример'
        end
      end
    end

    describe '.default_action' do
      subject(:default_action) { error_class.default_action }

      context 'when action is not defined' do
        let(:error_class) { described_class }

        it 'is eq :raise' do
          is_expected.to eq :raise
        end
      end

      context 'when on error action is defined' do
        let(:error_class) do
          Class.new(described_class) do
            on_error action: :catch
          end
        end

        it 'is eq error class name' do
          is_expected.to eq :catch
        end
      end
    end
  end
end
