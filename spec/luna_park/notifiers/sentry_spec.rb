# frozen_string_literal: true

require 'spec_helper'
require 'luna_park/notifiers/sentry'

module LunaPark
  RSpec.describe Notifiers::Sentry do
    let(:notifier) { described_class.new }
    let(:sentry_driver) { class_double(::Sentry, capture_exception: true, capture_message: true) }

    before do
      notifier.dependencies = {
        driver: -> { sentry_driver }
      }
    end

    describe '#post' do
      context 'when message is not exception' do
        context 'when message is object' do
          subject(:post_message) { notifier.post double(inspect: 'Something went wrong') }

          it 'should notify sentry with text of defined message' do
            expect(sentry_driver).to receive(:capture_message).with(
              'Something went wrong', extra: {}, level: :error
            )
            post_message
          end
        end

        context 'when message is string' do
          subject(:post_message) { notifier.post 'Something went wrong' }

          it 'should notify sentry with text of defined message' do
            expect(sentry_driver).to receive(:capture_message).with(
              'Something went wrong', extra: {}, level: :error
            )
            post_message
          end
        end
      end

      context 'when message is custom error' do
        let(:custom_error) { Class.new(RuntimeError) }
        let(:error) { custom_error.new('Something went wrong. Again.') }

        subject(:post_message) { notifier.post error }

        it 'should notify sentry with CustomError' do
          expect(sentry_driver).to receive(:capture_exception).with(
            error, extra: {}, level: :error
          )
          post_message
        end
      end

      context 'when severity level is not defined' do
        subject(:post_message) { notifier.post('Something went wrong') }

        it 'should notify sentry with `error` severity level' do
          expect(sentry_driver).to receive(:capture_message).with(
            'Something went wrong', extra: {}, level: :error
          )
          post_message
        end
      end

      context 'when severity level is debug' do
        subject(:post_message) { notifier.post('Something went wrong', lvl: :debug) }

        it 'should notify sentry with `debug` severity level' do
          expect(sentry_driver).to receive(:capture_message).with(
            'Something went wrong', extra: {}, level: :debug
          )
          post_message
        end
      end

      context 'when severity level is info' do
        subject(:post_message) { notifier.post('Something went wrong', lvl: :info) }

        it 'should notify sentry with `info` severity level' do
          expect(sentry_driver).to receive(:capture_message).with(
            'Something went wrong', extra: {}, level: :info
          )
          post_message
        end
      end

      context 'when severity level is warning' do
        subject(:post_message) { notifier.post('Something went wrong', lvl: :warning) }

        it 'should notify sentry with `warning` severity level' do
          expect(sentry_driver).to receive(:capture_message).with(
            'Something went wrong', extra: {}, level: :warning
          )
          post_message
        end
      end

      context 'when severity level is error' do
        subject(:post_message) { notifier.post('Something went wrong', lvl: :error) }

        it 'should notify sentry with `error` severity level' do
          expect(sentry_driver).to receive(:capture_message).with(
            'Something went wrong', extra: {}, level: :error
          )
          post_message
        end
      end

      context 'when severity level is fatal' do
        subject(:post_message) { notifier.post('Something went wrong', lvl: :fatal) }

        it 'should notify sentry with `error` severity level' do
          expect(sentry_driver).to receive(:capture_message).with(
            'Something went wrong', extra: {}, level: :fatal
          )
          post_message
        end
      end

      context 'when severity level is unknown' do
        subject(:post_message) { notifier.post('Something went wrong', lvl: :unknown) }

        it 'should notify sentry with `error` severity level' do
          expect(sentry_driver).to receive(:capture_message).with(
            'Something went wrong', extra: {}, level: :unknown
          )
          post_message
        end
      end

      context 'when details is not defined' do
        subject(:post_message) { notifier.post('Something went wrong') }

        it 'should not send empty extra information' do
          expect(sentry_driver).to receive(:capture_message).with(
            'Something went wrong', extra: {}, level: :error
          )
          post_message
        end
      end
      context 'when details is defined in post' do
        subject(:post_message) { notifier.post('Something went wrong', something: :wrong) }

        it 'should be send' do
          expect(sentry_driver).to receive(:capture_message).with(
            'Something went wrong', extra: { something: :wrong }, level: :error
          )
          post_message
        end
      end

      context 'when details is defined in message' do
        let(:msg) { double(details: { answer: 42 }) }

        before do
          allow(msg).to receive(:inspect).and_return 'Answer to the Ultimate Question of Life, the Universe and Everything'
        end

        subject(:post_message) { notifier.post(msg) }

        it 'should be send with' do
          expect(sentry_driver).to receive(:capture_message).with(
            'Answer to the Ultimate Question of Life, the Universe and Everything',
            extra: { answer: 42 }, level: :error
          )
          post_message
        end
      end

      context 'when details is defined in error and in post with same key' do
        let(:msg) { double(details: { answer: 42 }) }

        before do
          allow(msg).to receive(:inspect).and_return 'Answer to the Ultimate Question of Life, the Universe and Everything'
        end

        subject(:post_message) { notifier.post(msg, answer: 41) }

        it 'should be send with' do
          expect(sentry_driver).to receive(:capture_message).with(
            'Answer to the Ultimate Question of Life, the Universe and Everything',
            extra: { answer: { message: 42, post: 41 } }, level: :error
          )
          post_message
        end
      end
    end
  end
end
