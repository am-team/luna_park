# frozen_string_literal: true

require 'pp'

module LunaPark
  module Notifiers
    class Stdout
      class << self
        def error(msg, details = {})
          logger.error format(msg, details)
        end

        def warning(msg, details = {})
          logger.warning format(msg, details)
        end

        def info(msg, details = {})
          logger.info format(msg, details)
        end

        def debug(msg, details = {})
          logger.debug format(msg, details)
        end

        private

        def logger
          @logger ||= Logger.new(STDOUT)
        end

        def format(msg, details)
          details.merge!(msg.details) if msg.is_a? LunaPark::Errors::Processing

          return msg.to_s if details.empty?

          PP.pp({ mgs: msg.to_s, details: details }, '')
        end
      end
    end
  end
end
