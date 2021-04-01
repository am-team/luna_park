# frozen_string_literal: true

require 'luna_park/extensions/severity_levels'
require 'luna_park/extensions/injector'
require 'sentry-ruby'

module LunaPark
  module Notifiers
    class Sentry
      include LunaPark::Extensions::Injector
      include Extensions::SeverityLevels

      dependency(:driver) { ::Sentry }

      def initialize(min_lvl: :debug)
        self.min_lvl = min_lvl
      end

      def post(msg, lvl: :error, **details)
        raise ArgumentError, "Undefined severity level `#{lvl}`" unless LEVELS.include? lvl

        message = wrap msg
        details = extend details, with: msg

        if message.is_a?(Exception)
          driver.capture_exception(message, extra: details, level: lvl)
        else
          driver.capture_message(message, extra: details, level: lvl)
        end
      end

      private

      def wrap(message)
        return message if [Exception, String].any? { |type| message.is_a?(type) }

        message.inspect
      end

      def extend(details, with:)
        msg = with
        return details unless msg.respond_to?(:details)

        msg.details.merge(details) do |_, msg_value, post_value|
          { message: msg_value, post: post_value }
        end
      end
    end
  end
end
