# frozen_string_literal: true

require 'luna_park/extensions/severity_levels'

module LunaPark
  RSpec.describe Extensions::SeverityLevels do
    let(:fake_notifier) do
      Class.new do
        include Extensions::SeverityLevels

        def post(msg = '', lvl:, **details)
          { msg:, lvl:, details: }
        end
      end
    end

    let(:notifier) { fake_notifier.new }

    describe '#min_lvl' do
      subject { notifier.min_lvl }

      context 'when undefined' do
        it { is_expected.to eq :debug }
      end

      context 'when defined' do
        before { notifier.min_lvl = :warning }

        it 'should to be eq defined level' do
          is_expected.to eq :warning
        end
      end
    end

    describe '#min_lvl=' do
      context 'when set undefined value' do
        it { expect { notifier.min_lvl = :undefined }.to raise_error ArgumentError }
      end

      context 'when set undefined value' do
        it 'should to change minimum severity level' do
          expect { notifier.min_lvl = :warning }.to change { notifier.min_lvl }.from(:debug).to(:warning)
        end
      end
    end

    shared_examples 'can post message with severity level' do |lvl|
      context 'when message is object' do
        subject { notifier.send(lvl, 'Message text', foo: 1) }

        it 'should send expected message' do
          is_expected.to eq(msg: 'Message text', lvl:, details: { foo: 1 })
        end
      end

      context 'when message is block' do
        subject { notifier.send(lvl, foo: 1) { 'Message text' } }
        it 'should send expected message' do
          is_expected.to eq(msg: 'Message text', lvl:, details: { foo: 1 })
        end

        it 'should change run code in block' do
          msg = 'Old value'
          expect do
            notifier.send(lvl, foo: 1) { msg = 'New value' }
          end.to change { msg }.from('Old value').to('New value')
        end
      end
    end

    shared_examples 'can not post message with severity level' do |lvl|
      context 'when message is object' do
        subject { notifier.send(lvl, 'Message text', foo: 1) }

        it('should not send expected message') { is_expected.to be_nil }
      end

      context 'when message is block' do
        subject { notifier.send(lvl, foo: 1) { 'Message text' } }

        it('should not send expected message') { is_expected.to be_nil }

        it 'should not change run code in block' do
          msg = 'Old value'
          expect { notifier.send(lvl, foo: 1) { msg = 'New value' } }.to_not change { msg }
        end
      end
    end

    context 'when min severity level is debug' do
      before { notifier.min_lvl = :debug }

      it_behaves_like 'can post message with severity level', :unknown
      it_behaves_like 'can post message with severity level', :fatal
      it_behaves_like 'can post message with severity level', :error
      it_behaves_like 'can post message with severity level', :warning
      it_behaves_like 'can post message with severity level', :info
      it_behaves_like 'can post message with severity level', :debug
    end

    context 'when min severity level is info' do
      before { notifier.min_lvl = :info }

      it_behaves_like 'can post message with severity level', :unknown
      it_behaves_like 'can post message with severity level', :fatal
      it_behaves_like 'can post message with severity level', :error
      it_behaves_like 'can post message with severity level', :warning
      it_behaves_like 'can post message with severity level', :info
      it_behaves_like 'can not post message with severity level', :debug
    end

    context 'when min severity level is warning' do
      before { notifier.min_lvl = :warning }

      it_behaves_like 'can post message with severity level', :unknown
      it_behaves_like 'can post message with severity level', :fatal
      it_behaves_like 'can post message with severity level', :error
      it_behaves_like 'can post message with severity level', :warning
      it_behaves_like 'can not post message with severity level', :info
      it_behaves_like 'can not post message with severity level', :debug
    end

    context 'when min severity level is error' do
      before { notifier.min_lvl = :error }

      it_behaves_like 'can post message with severity level', :unknown
      it_behaves_like 'can post message with severity level', :fatal
      it_behaves_like 'can post message with severity level', :error
      it_behaves_like 'can not post message with severity level', :warning
      it_behaves_like 'can not post message with severity level', :info
      it_behaves_like 'can not post message with severity level', :debug
    end

    context 'when min severity level is fatal' do
      before { notifier.min_lvl = :fatal }

      it_behaves_like 'can post message with severity level', :unknown
      it_behaves_like 'can post message with severity level', :fatal
      it_behaves_like 'can not post message with severity level', :error
      it_behaves_like 'can not post message with severity level', :warning
      it_behaves_like 'can not post message with severity level', :info
      it_behaves_like 'can not post message with severity level', :debug
    end

    context 'when min severity level is unknown' do
      before { notifier.min_lvl = :unknown }

      it_behaves_like 'can post message with severity level', :unknown
      it_behaves_like 'can not post message with severity level', :fatal
      it_behaves_like 'can not post message with severity level', :error
      it_behaves_like 'can not post message with severity level', :warning
      it_behaves_like 'can not post message with severity level', :info
      it_behaves_like 'can not post message with severity level', :debug
    end
  end
end
