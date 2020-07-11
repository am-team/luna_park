# frozen_string_literal: true

require 'luna_park/notifiers/log'

module LunaPark
  RSpec.describe Notifiers::Log do
    let(:logger)   { double }
    let(:format)   { :single }
    let(:notifier) { described_class.new(logger: logger, format: format) }

    describe '#format' do
      subject { notifier.format }

      context 'when defined in initialize method' do
        let(:notifier) { described_class.new(logger: logger, format: :json) }

        it 'should eq defined value' do
          is_expected.to eq :json
        end
      end

      context 'when undefined in initialize method' do
        let(:notifier) { described_class.new(logger: logger) }

        it { is_expected.to eq :single }
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

        it 'should return only message' do
          expect(posted_message.output).to eq 'Message example'
        end
      end

      context 'when post has details' do
        subject(:posted_message) { notifier.post('Message example', mark: 'Important') }

        it 'should return message and details' do
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

        it 'should return message, message details and object details' do
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

        it 'should return message, and separated details of message and object' do
          expect(posted_message.output).to include 'Answer to the Ultimate Question of Life, the Universe and Everything'
          expect(posted_message.output).to include ':answer=>{:message=>41, :object=>42}'
        end
      end

      context 'when format is `:single`' do
        let(:format) { :single }

        context 'and message and object has not details' do
          subject(:posted_message) { notifier.post('Something interesting') }

          it 'should return only message text' do
            expect(posted_message.output).to eq 'Something interesting'
          end
        end

        context 'and message or object has details' do
          subject(:posted_message) { notifier.post('You hear', cat: 'mow') }

          it 'should return message text with details' do
            expect(posted_message.output).to eq 'You hear {:cat=>"mow"}'
          end
        end
      end

      context 'when output format is `:string`' do
        let(:format) { :string }

        context 'and message and object has not details' do
          subject(:posted_message) { notifier.post('Nothing interesting') }

          it 'should return only message text' do
            expect(posted_message.output).to eq 'Nothing interesting'
          end
        end

        context 'and message or object has details' do
          subject(:posted_message) { notifier.post('You hear', dog: 'wow') }

          it 'should return message text with details' do
            expect(posted_message.output).to eq 'You hear {:dog=>"wow"}'
          end
        end
      end

      context 'when output format is `:string`' do
        let(:format) { :string }

        context 'and message and object has not details' do
          subject(:posted_message) { notifier.post('Nothing interesting') }

          it 'should return only message text' do
            expect(posted_message.output).to eq 'Nothing interesting'
          end
        end

        context 'and message or object has details' do
          subject(:posted_message) { notifier.post('You hear', dog: 'wow') }

          it 'should return message text with details' do
            expect(posted_message.output).to eq 'You hear {:dog=>"wow"}'
          end
        end
      end

      context 'when output format is `:json`' do
        let(:format) { :json }
        subject(:posted_message) { notifier.post('You hear', dog: 'wow') }

        it 'should return message text with details in json format' do
          expect(posted_message.output).to eq '{"message":"You hear","details":{"dog":"wow"}}'
        end
      end

      context 'when output format is `:multiline`' do
        let(:format) { :multiline }
        subject(:posted_message) { notifier.post('You hear', dog: 'wow', cats: { chloe: 'mow', timmy: 'mow' }) }

        it 'should return message with details in the form of a hash divided into several lines' do
          expect(posted_message.output).to eq <<~MULTILINE.chomp # heredoc has newline symbol at the end, chomp it
            {:message=>\"You hear\",
             :details=>{:dog=>\"wow\", :cats=>{:chloe=>\"mow\", :timmy=>\"mow\"}}}\n
          MULTILINE
        end
      end

      context 'when output format is `:pretty_json`' do
        let(:format) { :pretty_json }
        subject(:posted_message) { notifier.post('You hear', dog: 'wow', cats: { chloe: 'mow', timmy: 'mow' }) }

        it 'should return message with details in the form of a json divided into several lines' do
          expect(posted_message.output).to eq <<~JSON_OUTPUT.chomp # heredoc has newline symbol at the end, chomp it
            {
              "message": "You hear",
              "details": {
                "dog": "wow",
                "cats": {
                  "chloe": "mow",
                  "timmy": "mow"
                }
              }
            }
          JSON_OUTPUT
        end
      end

      context 'when format is unknown' do
        let(:format) { :unknown }
        subject(:posted_message) { notifier.post('You hear', dog: 'wow', cats: { chloe: 'mow', timmy: 'mow' }) }

        it { expect { subject }.to raise_error ArgumentError }
      end
    end
  end
end
