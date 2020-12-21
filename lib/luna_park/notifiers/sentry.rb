# frozen_string_literal: true

require 'luna_park/extensions/severity_levels'
require 'luna_park/extensions/injector'
require 'sentry-raven'

module LunaPark
  module Notifiers
    class Sentry
      include LunaPark::Extensions::SeverityLevels
      include LunaPark::Extensions::Injector

      dependency(:driver) { Raven }

      def initialize(min_lvl: :debug)
        self.min_lvl = min_lvl
      end

      def post(msg, lvl: :error, **details)
        raise ArgumentError, "Undefined severity level `#{lvl}`" unless LEVELS.include? lvl

        message = wrap msg
        details = extend details, with: msg

        driver.capture_message(message, extra: details, level: lvl)
      end

      private

      def wrap(msg)
        msg.is_a?(Exception) || msg.is_a?(String) ? msg : msg.inspect
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
