# frozen_string_literal: true

require 'webmock/rspec'
require 'luna_park/notifiers/bugsnag'

module BugsnagSpec
  class CustomError < RuntimeError
  end
end

module LunaPark
  RSpec.describe Notifiers::Bugsnag do
    before(:each) do
      ::Bugsnag.instance_variable_set(:@configuration, ::Bugsnag::Configuration.new)
      ::Bugsnag.configure do |bugsnag|
        bugsnag.api_key = 'c9d60ae4c7e70c4b6c4ebd3e8056d2b8'
        bugsnag.release_stage = 'production'
        bugsnag.delivery_method = :synchronous
        # silence logger in tests
        bugsnag.logger = Logger.new(StringIO.new)
      end

      stub_request(:any, 'https://notify.bugsnag.com')
    end

    let(:notifier) { described_class.new }

    describe '#post' do
      context 'when message is not exception' do
        let(:msg) { double(inspect: 'Something went wrong') }

        subject(:post_message) { notifier.post(msg) }

        it 'should notify bugsnag with RuntimeError and defined message' do
          post_message
          expect(notifier).to have_sent_bugsnag_notification { |error, message|
            expect(error).to   eq 'RuntimeError'
            expect(message).to eq 'Something went wrong'
          }
        end
      end

      context 'when message is custom error' do
        subject(:post_message) { notifier.post BugsnagSpec::CustomError.new('Something went wrong. Again.') }

        it 'should notify bugsnag with CustomError' do
          post_message
          expect(notifier).to have_sent_bugsnag_notification { |error, message|
            expect(error).to   eq 'BugsnagSpec::CustomError'
            expect(message).to eq 'Something went wrong. Again.'
          }
        end
      end

      context 'when severity level is not defined' do
        subject(:post_message) { notifier.post('Something went wrong') }

        it 'should notify bugsnag with `error` severity level' do
          post_message
          expect(notifier).to have_sent_bugsnag_notification { |_e, _m, severity|
            expect(severity).to eq 'error'
          }
        end
      end

      context 'when severity level is debug' do
        subject(:post_message) { notifier.post('Something went wrong', lvl: :debug) }

        it 'should notify bugsnag with `debug` severity level' do
          post_message
          expect(notifier).to have_sent_bugsnag_notification { |_e, _m, severity|
            expect(severity).to eq 'debug'
          }
        end
      end

      context 'when severity level is info' do
        subject(:post_message) { notifier.post('Something went wrong', lvl: :info) }

        it 'should notify bugsnag with `info` severity level' do
          post_message
          expect(notifier).to have_sent_bugsnag_notification { |_e, _m, severity|
            expect(severity).to eq 'info'
          }
        end
      end

      context 'when severity level is warning' do
        subject(:post_message) { notifier.post('Something went wrong', lvl: :warning) }

        it 'should notify bugsnag with `warning` severity level' do
          post_message
          expect(notifier).to have_sent_bugsnag_notification { |_e, _m, severity|
            expect(severity).to eq 'warning'
          }
        end
      end

      context 'when severity level is error' do
        subject(:post_message) { notifier.post('Something went wrong', lvl: :error) }

        it 'should notify bugsnag with `error` severity level' do
          post_message
          expect(notifier).to have_sent_bugsnag_notification { |_e, _m, severity|
            expect(severity).to eq 'error'
          }
        end
      end

      context 'when severity level is fatal' do
        subject(:post_message) { notifier.post('Something went wrong', lvl: :fatal) }

        it 'should notify bugsnag with `error` severity level' do
          post_message
          expect(notifier).to have_sent_bugsnag_notification { |_e, _m, severity, _d, custom|
            expect(severity).to eq 'error'
            expect(custom).to eq('original_message_severity' => 'fatal')
          }
        end
      end

      context 'when severity level is unknown' do
        subject(:post_message) { notifier.post('Something went wrong', lvl: :unknown) }

        it 'should notify bugsnag with `error` severity level' do
          post_message
          expect(notifier).to have_sent_bugsnag_notification { |_e, _m, severity, _d, custom|
            expect(severity).to eq 'error'
            expect(custom).to eq('original_message_severity' => 'unknown')
          }
        end
      end

      context 'when details is not defined' do
        subject(:post_message) { notifier.post('Something went wrong') }

        it 'should not be send' do
          post_message
          expect(notifier).to have_sent_bugsnag_notification { |_e, _m, _s, details|
            expect(details).to be_empty
          }
        end
      end

      context 'when details is defined in post' do
        subject(:post_message) { notifier.post('Something went wrong', something: :wrong) }

        it 'should be send' do
          post_message
          expect(notifier).to have_sent_bugsnag_notification { |_e, _m, _s, details|
            expect(details).to eq('something' => 'wrong')
          }
        end
      end

      context 'when details is defined in message' do
        let(:msg) { double(details: { answer: 42 }) }

        before do
          allow(msg).to receive(:to_s).and_return 'Answer to the Ultimate Question of Life, the Universe and Everything'
        end

        subject(:post_message) { notifier.post(msg) }

        it 'should be send with' do
          post_message
          expect(notifier).to have_sent_bugsnag_notification { |_e, _m, _s, details|
            expect(details).to eq('answer' => 42)
          }
        end
      end

      context 'when details is defined in error and in post with same key' do
        let(:msg) { double(details: { answer: 42 }) }

        before do
          allow(msg).to receive(:to_s).and_return 'Answer to the Ultimate Question of Life, the Universe and Everything'
        end

        subject(:post_message) { notifier.post(msg, answer: 41) }

        it 'should be send with' do
          post_message
          expect(notifier).to have_sent_bugsnag_notification { |_e, _m, _s, details|
            expect(details).to eq('answer' => { 'message' => 42, 'post' => 41 })
          }
        end
      end

      # @example
      #   expect(notifier).to have_sent_bugsnag_notification { |_e, _m, sent_severity|
      #     expect(sent_severity).to eq 'warning'
      #   }
      def have_sent_bugsnag_notification(&block)
        have_requested(:post, 'https://notify.bugsnag.com/').with do |request|
          raise 'no block provided to have_sent_bugsnag_notification (did you use { })' unless block

          event = JSON.parse(request.body).dig('events', 0)
          error_class = event.dig('exceptions', 0, 'errorClass')
          message     = event.dig('exceptions', 0, 'message')
          severity    = event['severity']
          details     = event.dig('metaData', 'details')
          custom      = event.dig('metaData', 'custom')

          block.call(error_class, message, severity, details, custom)
          true
        end
      end
    end
  end
end
