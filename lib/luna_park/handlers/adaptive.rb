# frozen_string_literal: true

require 'luna_park/errors'

module LunaPark
  module Handlers
    class Adaptive
      def initialize(notifier: Notifier::Stdout, locale: nil)
        @notifier = notifier
        @locale   = locale
      end

      def catch
        yield
        on_success
      rescue Errors::Adaptive => e
        notify(e) if e.notify?
        handle(e)
        on_error
      end

      def self.catch(notifier: Notifiers::Stdout, locale: nil)
        new(notifier: notifier, locale: locale).catch { yield }
      end

      def on_success; end

      def on_error; end

      private

      attr_reader :notifier, :locale

      def handle(error)
        case error.action
        when :stop  then on_stop
        when :catch then on_catch(error)
        when :raise then on_raise(error)
        else raise ArgumentError, "Unknown error action #{error.action}"
        end
      end

      def notify(error)
        case error.notify_lvl
        when :error   then notifier.error(error)
        when :warning then notifier.warning(error)
        when :info    then notifier.info(error)
        else raise ArgumentError, "Unknown error notify level #{error.action}"
        end
      end

      def on_stop
        nil
      end

      def on_catch(error)
        error.message(locale: locale)
      end

      def on_raise(error)
        raise error, error.message(locale: locale)
      end
    end
  end
end
