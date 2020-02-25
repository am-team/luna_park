# frozen_string_literal: true

require 'luna_park/handlers/adaptive'

module LunaPark
  RSpec.describe Handlers::Adaptive do
    subject(:action) do
      described_class.catch(notifier: notifier) do
        raise error if 1 > 0

        :action_result
      end
    end

    let(:notifier) { double error: 'foobar', warning: 'warning', info: 'info' }

    context 'when action on error is `stop`' do
      let(:error) do
        Class.new(Errors::Adaptive) do
          on_error action: :stop
        end
      end

      it { is_expected.to eq nil }
    end

    context 'when action on error is `catch`' do
      let(:error) do
        Class.new(Errors::Adaptive) do
          message 'Error example'
          on_error action: :catch
        end
      end

      it { is_expected.to be_instance_of(String) }
    end

    context 'when action on error is `raise`' do
      let(:error) do
        Class.new(Errors::Adaptive) do
          message 'Error example'
          on_error action: :raise
        end
      end

      it { expect { action }.to raise_error(error) }
    end

    context 'when error should be notified' do
      let(:error) do
        Class.new(Errors::Adaptive) do
          message 'Error example'
          on_error action: :catch, notify: true
        end
      end

      it 'should send notify message' do
        expect(notifier).to receive(:error)
        action
      end
    end

    context 'when error notify level is error' do
      let(:error) do
        Class.new(Errors::Adaptive) do
          message 'Error example'
          on_error action: :catch, notify: :error
        end
      end

      it 'should send notify message' do
        expect(notifier).to receive(:error)
        action
      end
    end

    context 'when error notify level is warning' do
      let(:error) do
        Class.new(Errors::Adaptive) do
          message 'Error example'
          on_error action: :catch, notify: :warning
        end
      end

      it 'should send notify message' do
        expect(notifier).to receive(:warning)
        action
      end
    end

    context 'when error notify level is info' do
      let(:error) do
        Class.new(Errors::Adaptive) do
          message 'Error example'
          on_error action: :catch, notify: :info
        end
      end

      it 'should send notify message' do
        expect(notifier).to receive(:info)
        action
      end
    end

    context 'when error notify is disabled' do
      let(:error) do
        Class.new(Errors::Adaptive) do
          message 'Error example'
          on_error action: :catch, notify: false
        end
      end

      it 'should send notify message' do
        expect(notifier).to_not receive(:error)
        expect(notifier).to_not receive(:warning)
        expect(notifier).to_not receive(:info)
        action
      end
    end

    context 'when error notify undefined' do
      let(:error) do
        Class.new(Errors::Adaptive) do
          message 'Error example'
          on_error action: :catch
        end
      end

      it 'should send notify message' do
        expect(notifier).to_not receive(:error)
        expect(notifier).to_not receive(:warning)
        expect(notifier).to_not receive(:info)
        action
      end
    end
  end
end
