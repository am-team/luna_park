# frozen_string_literal: true

require 'luna_park/notifiers/log'

module LunaPark
  RSpec.describe Notifiers::Log do
    let(:logger)    { double }
    let(:formatter) { Notifiers::Log::Formatters::SINGLE }
    let(:notifier)  { described_class.new(logger: logger, formatter: formatter) }

    describe '#formatter' do
      subject { notifier.formatter }

      context 'when defined in initialize method' do
        let(:notifier) { described_class.new(logger: logger, formatter: Notifiers::Log::Formatters::JSON) }

        it 'should eq defined value' do
          is_expected.to eq Notifiers::Log::Formatters::JSON
        end
      end

      context 'when undefined in initialize method' do
        let(:notifier) { described_class.new(logger: logger) }

        it { is_expected.to eq Notifiers::Log::Formatters::SINGLE }
      end

      context 'when format param used to set formatter' do
        let(:notifier) { described_class.new(logger: logger, format: :json) }

        it { is_expected.to eq Notifiers::Log::Formatters::JSON }
      end
    end

    describe '#logger' do
      subject(:logger) { notifier.logger }

      context 'does not specify' do
        let(:notifier) { described_class.new }

        it { is_expected.to be_an_instance_of Logger }

        # It's really dirty, like code of logger class
        it 'should output to stdout' do
          expect(logger.instance_variable_get(:@logdev).instance_variable_get(:@dev)).to eq STDOUT
        end
      end

      context 'defined in class' do
        class FakeLogger; end

        let(:log_class) do
          Class.new(described_class) { logger FakeLogger }
        end

        let(:notifier) { log_class.new }

        it 'should be expected driver' do
          is_expected.to eq FakeLogger
        end
      end

      context 'defined at initialize of instance' do
        class FakeLogger; end
        let(:notifier) { described_class.new logger: FakeLogger }

        it 'should be expected driver' do
          is_expected.to eq FakeLogger
        end
      end
    end

    describe '#message' do
      class TestLogger
        attr_reader :severity, :output

        def initialize(severity, output)
          @severity = severity
          @output = output
        end

        def self.add(severity, obj)
          new(severity, obj)
        end
      end

      let(:logger) { TestLogger }

      context 'when message has not details' do
        subject(:posted_message) { notifier.post('Message example') }

        it 'should return message and class' do
          expect(posted_message.output).to eq '#<String> Message example'
        end
      end

      context 'when post has details' do
        subject(:posted_message) { notifier.post('Message example', mark: 'Important') }

        it 'should return class,message and details' do
          expect(posted_message.output).to include 'String'
          expect(posted_message.output).to include 'Message example'
          expect(posted_message.output).to include ':mark=>"Important"'
        end
      end

      context 'when post and message object has details' do
        let(:message) { double(details: { answer: 42 }) }

        before do
          allow(message).to receive(:to_s).and_return 'Answer to the Ultimate Question of Life, the Universe and Everything'
        end

        subject(:posted_message) { notifier.post(message, mark: 'Important') }

        it 'should return class, message, message details and object details' do
          expect(posted_message.output).to include message.class.to_s
          expect(posted_message.output).to include 'Answer to the Ultimate Question of Life, the Universe and Everything'
          expect(posted_message.output).to include ':answer=>42'
          expect(posted_message.output).to include ':mark=>"Important"'
        end
      end

      context 'when message and object details has same key' do
        let(:message) { double(details: { answer: 42 }) }

        before do
          allow(message).to receive(:to_s).and_return 'Answer to the Ultimate Question of Life, the Universe and Everything'
        end

        subject(:posted_message) { notifier.post(message, answer: 41) }

        it 'should return class, message, and separated details of message and object' do
          expect(posted_message.output).to include message.class.to_s
          expect(posted_message.output).to include ' Answer to the Ultimate Question of Life, the Universe and Everything'
          expect(posted_message.output).to include ':answer=>{:message=>41, :object=>42}'
        end
      end
    end
  end
end
