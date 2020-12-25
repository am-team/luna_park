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
            message 'Static message'
          end
        end

        context 'message is not defined on initialization error object' do
          subject(:message) { error.new.message }

          it 'should be eq class name' do
            is_expected.to eq 'Static message'
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

      context 'message defined with block' do
        subject(:message) { error.new(foo: 'FOO').message }

        let(:error) do
          Class.new(described_class) do
            message { |d| "Dynamic message with variable '#{d[:foo]}'" }
          end
        end

        it 'should be expected dynamic message' do
          is_expected.to eq "Dynamic message with variable 'FOO'"
        end
      end
    end

    describe '#localized_message' do
      subject(:localized_message) { error.new.localized_message(:ru) }

      let(:error) do
        Class.new(described_class) do
          message 'Static message', i18n_key: 'errors.example'
        end
      end

      it 'is equal to expected message at default locale' do
        is_expected.to eq 'Пример'
      end

      context 'when i18n_key is not specified' do
        subject(:localized_message) { error.new.localized_message(:en) }

        let(:error) do
          Class.new(described_class) do
            message 'Static message'
          end
        end

        it { is_expected.to be_nil }
      end

      context 'when locale is not given' do
        subject(:localized_message) { error.new.localized_message }

        let(:error) do
          Class.new(described_class) do
            message 'Static message', i18n_key: 'errors.example'
          end
        end

        it 'is equal to expected message at default locale' do
          is_expected.to eq I18n.t('errors.example', locale: I18n.default_locale)
        end
      end

      context 'with details as variables' do
        subject(:localized_message) { error.new(variable: 'FOO', extra: 'bar').localized_message(:en) }

        let(:error) do
          Class.new(described_class) do
            message 'Static message', i18n_key: 'errors.variable'
          end
        end

        it 'contains details in translation' do
          is_expected.to eq 'Example with "FOO" variable'
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
          message 'Static message', i18n_key: 'errors.example_key'
        end
      end

      it 'defines build_message' do
        expect(error_class.build_message).to be_a Proc
      end

      it 'defines build_message that builds expected message' do
        expect(error_class.build_message.call({})).to eq 'Static message'
      end

      it 'defines 118n_key' do
        expect(error_class.i18n_key).to eq 'errors.example_key'
      end

      context 'when use default message block' do
        let(:error_class) do
          Class.new(described_class) do
            message(i18n_key: 'errors.example_key') { |d| "Dynamic message #{d[:foo]}" }
          end
        end

        it 'defines build_message that builds expected message' do
          expect(error_class.build_message.call({ foo: 'Foo' })).to eq 'Dynamic message Foo'
        end
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

    describe '.build_message' do
      subject(:build_message) { error_class.build_message }

      context 'when default message is not defined' do
        let(:error_class) { described_class }

        it 'is nil' do
          is_expected.to be_nil
        end
      end

      context 'when default message is defined' do
        let(:error_class) do
          Class.new(described_class) do
            message 'Static message'
          end
        end

        it 'is a Proc' do
          is_expected.to be_a Proc
        end

        it 'can build defined message' do
          expect(build_message.call({})).to eq 'Static message'
        end
      end

      context 'when default message is defined with block' do
        let(:error_class) do
          Class.new(described_class) do
            message { |d| "Message with detail '#{d[:detail]}'" }
          end
        end

        it 'is a Proc' do
          is_expected.to be_a Proc
        end

        it 'can build expected message' do
          expect(build_message.call({ detail: 'DETAIL' })).to eq "Message with detail 'DETAIL'"
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
