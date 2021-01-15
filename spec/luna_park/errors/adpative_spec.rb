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

      context 'message is given on initialization' do
        subject(:message) { described_class.new('given message').message }

        it 'should be eq class name' do
          is_expected.to eq 'given message'
        end
      end

      context 'message is defined in class by string' do
        let(:error_class) do
          Class.new(described_class) do
            message 'Static default message'
          end
        end

        context 'message is not defined on initialization error object' do
          subject(:message) { error_class.new.message }

          it 'should be eq class name' do
            is_expected.to eq 'Static default message'
          end
        end
      end

      context 'message defined in class by block' do
        subject(:message) { error_class.new(foo: 'FOO').message }

        let(:error_class) do
          Class.new(described_class) do
            message { |d| "Dynamic message with variable '#{d[:foo]}'" }
          end
        end

        it 'should be expected dynamic message' do
          is_expected.to eq "Dynamic message with variable 'FOO'"
        end
      end

      context 'message is defined with i18n' do
        let(:error) { error_class.new(foo: 'FOO') }
        let(:error_class) do
          Class.new(described_class) do
            message 'Static default message', i18n_key: 'errors.example'
          end
        end

        it 'is equal to expected message at default locale' do
          expect(error.message).to eq 'Example'
        end

        it 'is equal to expected message at given locale' do
          expect(error.message(locale: :fr)).to eq 'Exemple'
        end
      end
    end

    context 'message is defined with i18n, but has no default translation' do
      let(:error_class) do
        Class.new(described_class) do
          message 'Default message', i18n_key: 'foo'
        end
      end

      before { skip 'Not implemented yet' }

      it 'is equal to default message' do
        expect(error_class.new.message(locale: :en)).to eq 'Default message'
      end
    end

    context 'message is defined only with i18n, but has no default translation' do
      let(:error_class) do
        Class.new(described_class) do
          message i18n_key: 'errors.foo'
        end
      end

      it 'is equal to translation missing error text' do
        expect(error_class.new.message(locale: :en)).to eq 'translation missing: en.errors.foo'
      end
    end

    context 'message is defined with i18n that has interpolation' do
      subject(:message) { error_class.new(variable: 'FOO', extra: 'bar').message(locale: :en) }

      let(:error_class) do
        Class.new(described_class) do
          message 'Static default message', i18n_key: 'errors.variable'
        end
      end

      it 'contains details in translation' do
        is_expected.to eq 'Example with "FOO" variable'
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
          message 'Static default message', i18n_key: 'errors.example_key'
        end
      end

      it 'defines default_message_block' do
        expect(error_class.default_message_block).to be_a Proc
      end

      it 'defines default_message_block that builds expected message' do
        expect(error_class.default_message_block.call({})).to eq 'Static default message'
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

        it 'defines default_message_block that builds expected message' do
          expect(error_class.default_message_block.call({ foo: 'Foo' })).to eq 'Dynamic message Foo'
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

    describe '.default_message_block' do
      subject(:default_message_block) { error_class.default_message_block }

      context 'when default message is not defined' do
        let(:error_class) { described_class }

        it 'is nil' do
          is_expected.to be_nil
        end
      end

      context 'when default message is defined' do
        let(:error_class) do
          Class.new(described_class) do
            message 'Static default message'
          end
        end

        it 'is a Proc' do
          is_expected.to be_a Proc
        end

        it 'can build defined message' do
          expect(default_message_block.call({})).to eq 'Static default message'
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
          expect(default_message_block.call({ detail: 'DETAIL' })).to eq "Message with detail 'DETAIL'"
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
