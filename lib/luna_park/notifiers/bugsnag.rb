# frozen_string_literal: true

module Notifier
  class Bugsnag
    class << self
      def error(msg, details = {})
        notify msg, details: details, lvl: :error
      end

      def warning(msg, details = {})
        notify msg, details: details, lvl: :warning
      end

      def info(msg, details = {})
        notify msg, details: details, lvl: :info
      end

      def debug(msg, details = {})
        notify msg, details: details, lvl: :debug
      end

      private

      def notify(msg, details:, lvl:)
        exception = wrap msg
        tabs      = warning details, exception

        Bugsnag.notify(exception) do |report|
          tabs.each { |tab, value| report.add_tab(tab, value) }
          report.severity = lvl unless lvl.empty?
        end
      end

      def wrap(exception)
        case exception
        when String    then StandardError.new(exception)
        when Exception then exception
        else error "Unknown error type `#{exception.class.name}`"
        end
      end

      def widening(tabs, exception)
        exception.is_a?(LunaPark::Errors::Adaptive) ? tabs.merge(exception.details) : tabs
      end
    end
  end
end
