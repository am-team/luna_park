# frozen_string_literal: false

require 'logger'
require 'luna_park/extensions/severity_levels'
require 'luna_park/notifiers/log/formatters'
require 'luna_park/errors'

module LunaPark
  module Notifiers
    # Developers need a tool to help them analyze the application. Mostly they use loggers that display messages
    # in files or in STDOUT. But if you have a lot of microservices, analyzing the logs stored in files on different
    # servers can be a problem. You can use some real-time error tracking and debugging tools such as
    # Bugsnag, Rollbar, etc.
    #
    # Notifiers are an abstraction that breaks the dependency on a particular implementation of a developer's tool.
    # Current notifier implement abstraction over ruby logger.
    #
    # For example output to log file message at json format
    #   # Define logger and output destination file or STDOUT\STDERR
    #   logger   = Logger.new('./log/app.log')
    #
    #   # Set output format and minimum level output level
    #   notifier = LunaPark::Notifiers::Logger.new(logger: logger, format: :json, min_lvl: :debug)
    #   notifier.info 'Answer to the Ultimate Question of Life, the Universe and Everything', hint: '21 * 2'
    #
    # And you will get to './log/app.log'
    #   I, [2020-06-13T21:53:00.824304 #37992]  INFO -- : {"message":"Answer to the Ultimate Question of Life,
    #   the Universe and Everything","details":{"hint":"21 * 2"}}
    class Log
      include Extensions::SeverityLevels

      # Callable object to format log messages.
      #
      # pretty_formatter = ->(klass, message, details) { "#{klass} - #{message} - #{details}" }
      # notifier = LunaPark::Notifiers::Log.new(formatter: pretty_formatter)
      # notifier.info('You hear', dog: 'wow', cats: {chloe: 'mow', timmy: 'mow'})
      # => I, [2022-09-29T10:51:15.753646 #28763]  INFO -- : String - You hear - {:dog=>"wow", :cats=>{:chloe=>"mow", :timmy=>"mow"}}
      #
      attr_reader :formatter

      # Logger which used for output all notify. Should be instance of Logger class.
      # You can define it in two ways.
      # - On class
      #   class Stderr < LunaPark::Notifier::Log
      #     logger Logger.new('example.log')
      #   end
      #
      #   stderr = Stderr.new
      #   stderr.logger # => #<Logger:0x000056445e1e2118 ... @filename="example.log"...
      # Or in the initialize of the instance
      #
      # - On instance
      #   stderr = LunaPark::Notifier::Log.new(logger: Logger.new(STDERR))
      #   stderr.logger # => #<Logger:0x000056445e1e2118 ... @filename="example.log"...
      #
      # At default value is Logger.new(STDOUT)
      attr_reader :logger

      # Create new log notifier
      #
      # @param logger    - Logger which used for output all notify see #logger
      # @param formatter - Log messages formatter see #formatter
      # @param format    - Formatter name. Deprecated and will be removed in a future version
      # @param min_lvl   - What level should a message be for it to be processed by a notifier
      def initialize(logger: nil, format: nil, formatter: nil, min_lvl: :debug)
        @logger      = logger || self.class.default_logger
        @formatter   = formatter || Formatters::SINGLE
        # @todo Remove format param in the future version
        unless format.nil?
          @formatter = formatter_by_name(format)
          warn 'warn [DEPRECATION] `format` parameter is deprecated, use `formatter` instead'
        end
        self.min_lvl = min_lvl
      end

      # Send a notification to the log.
      #
      # @param  msg - Message object, usual String or Exception
      # @param [Symbol] lvl - Level of current message, can be :debug, :info, :warning, :error, :fatal or :unknown
      # @param [Hash] details - Any another details for current message
      def post(msg, lvl: :error, **details)
        severity = severity(lvl)
        message  = serialize(msg, details)
        logger.add severity, message
      end

      class << self
        def logger(val)
          @default_logger = val
        end

        def default_logger
          @default_logger ||= Logger.new(STDOUT)
        end
      end

      private

      SEVERITY_LEVELS = {
        unknown: Logger::Severity::UNKNOWN,
        fatal: Logger::Severity::FATAL,
        error: Logger::Severity::ERROR,
        warning: Logger::Severity::WARN,
        info: Logger::Severity::INFO,
        debug: Logger::Severity::DEBUG
      }.freeze

      private_constant :SEVERITY_LEVELS

      def severity(lvl)
        severity = SEVERITY_LEVELS[lvl]
        raise ArgumentError, "Unknown level #{lvl}" if severity.nil?

        severity
      end

      def extend(details, with:)
        message = with
        return details unless message.respond_to?(:details)

        (message.details || {}).merge(details || {}) do |_, object_value, message_value|
          { message: message_value, object: object_value }
        end
      end

      def serialize(obj, **details)
        details = extend(details, with: obj)
        formatter.call(obj.class, String(obj), details)
      end

      def formatter_by_name(name)
        case name
        when :json        then Formatters::JSON
        when :multiline   then Formatters::MULTILINE
        when :pretty_json then Formatters::PRETTY_JSON
        else Formatters::SINGLE
        end
      end
    end
  end
end
