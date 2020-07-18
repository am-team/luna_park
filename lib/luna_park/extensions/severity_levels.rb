# frozen_string_literal: true

module LunaPark
  module Extensions
    module SeverityLevels
      # This is class  define interface for loggers and notifiers behavior.
      # In main idea it based on rfc5424 https://tools.ietf.org/html/rfc5424, but
      # in fact default ruby logger does not define all severities, and we use only
      # most important:
      #  - unknown: an unknown message that should always be logged
      #  - fatal: An unhandleable error that results in a program crash
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
      #   logger.unknown 'Do not do that.' # => 'UNKNOWN: Do not do that.'
      #   logger.fatal 'Do not do that.'   # => 'FATAL: Do not do that.'
      #   logger.error 'Do not do that.'   # => 'ERROR: Do not do that.'
      #   logger.warning 'Do not do that.' # => 'WARNING: Do not do that.'
      #   logger.info 'Do not do that.'    # => nil
      #   logger.debug 'Do not do that.'   # => nil
      LEVELS = %i[debug info warning error fatal unknown].freeze

      # Defined minimum severity level
      def min_lvl
        @min_lvl ||= :debug
      end

      def min_lvl=(value)
        raise ArgumentError, 'Undefined severity level' unless LEVELS.include? value

        @min_lvl = value
      end

      # rubocop:disable Style/GuardClause

      # Post message with UNKNOWN severity level
      #
      # @param msg [String,Exception]
      # @param details [Hash]
      def unknown(msg = '', **details)
        message = block_given? ? yield : msg
        post message, lvl: :unknown, **details
      end

      # Post message with FATAL severity level
      #
      # @param msg [String,Exception]
      # @param details [Hash]
      def fatal(msg = '', **details)
        if %i[debug info warning error fatal].include? min_lvl
          message = block_given? ? yield : msg
          post message, lvl: :fatal, **details
        end
      end

      # Post message with ERROR severity level
      #
      # @param msg [String,Exception]
      # @param details [Hash]
      def error(msg = '', **details)
        if %i[debug info warning error].include? min_lvl
          message = block_given? ? yield : msg
          post message, lvl: :error, **details
        end
      end

      # Post stdout message with WARNING severity level
      #
      # @param msg [String,Exception]
      # @param details [Hash]
      def warning(msg = '', **details)
        if %i[debug info warning].include? min_lvl
          message = block_given? ? yield : msg
          post message, lvl: :warning, **details
        end
      end

      # Post message with INFO  severity level
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

      # Post message with DEBUG severity level
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
