# frozen_string_literal: true

require 'luna_park/extensions/severity_levels'
require 'bugsnag'

module LunaPark
  module Notifiers
    class Bugsnag
      include Extensions::SeverityLevels

      def initialize(min_lvl: :debug)
        self.min_lvl = min_lvl
      end

      def post(msg, lvl: :error, **details)
        raise ArgumentError, "Undefined severity level `#{lvl}`" unless LEVELS.include? lvl

        message = wrap msg
        details = extend details, with: msg
        ::Bugsnag.notify(message) do |report|
          report.add_tab(:details, details)
          report.severity = lvl
        end
      end

      private

      def wrap(msg)
        msg.is_a?(Exception) ? msg : String(msg)
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
