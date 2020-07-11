# frozen_string_literal: true

module LunaPark
  module Extensions
    module SeverityLevels
      # This is class  define interface for loggers and notifiers behavior.
      # In main idea it based on rfc5424 https://tools.ietf.org/html/rfc5424, but
      # in fact default ruby logger does not define all severities, and we use only
      # most important:
      #  - error: system work incorrectly, and maintainer should know about that immediately
      #  - warning: warning conditions, and maintainer should know about that, but not immediately
      #  - info: informational messages, maintainer should know about that, if they want to analyse logs
      #  - debug: debug messages, for developers don't use it on production
      #
      # @example
      #   class ChattyLogger < LunaPark::Notifiers::Abstract
      #     def message(obj, _details:, lvl:)
      #       puts "{lvl.upcase}: #{message}"
      #     end
      #   end
      #
      #   logger = ChattyLogger.new min_lvl: :warning
      #   logger.error 'Do not do that.'   # => 'ERROR: Do not do that.'
      #   logger.warning 'Do not do that.' # => 'WARNING: Do not do that.'
      #   logger.info 'Do not do that.'    # => nil
      #   logger.debug 'Do not do that.'   # => nil
      LEVELS = %i[debug info warning error].freeze

      # Defined minimum severity level
      def min_lvl
        @min_lvl ||= :warning
      end

      def min_lvl=(value)
        raise ArgumentError, 'Undefined severity level' unless LEVELS.include? value

        @min_lvl = value
      end

      # rubocop:disable Style/GuardClause

      # Send to message with ERROR lvl
      #
      # @param msg [String,Exception]
      # @param details [Hash]
      def error(msg = '', **details)
        message = block_given? ? yield : msg
        post message, lvl: :error, **details
      end

      # Send to stdout message with WARNING lvl
      #
      # @param msg [String,Exception]
      # @param details [Hash]
      def warning(msg = '', **details)
        if %i[debug info warning].include? min_lvl
          message = block_given? ? yield : msg
          post message, lvl: :warning, **details
        end
      end

      # Send to stdout message with INFO lvl
      #
      # @example
      #
      # @param msg [String,Exception]
      # @param details [Hash]
      def info(msg = '', **details)
        if %i[debug info].include? min_lvl
          message = block_given? ? yield : msg
          post message, lvl: :info, **details
        end
      end

      # Send to stdout message with DEBUG lvl
      #
      # @param msg [String,Exception]
      # @param details [Hash]
      def debug(msg = '', **details)
        if min_lvl == :debug
          message = block_given? ? yield : msg
          post message, lvl: :debug, **details
        end
      end

      # rubocop:enable Style/GuardClause

      # @abstract
      def post(_msg = '', _lvl:, **_details)
        raise Errors::AbstractMethod
      end
    end
  end
end
