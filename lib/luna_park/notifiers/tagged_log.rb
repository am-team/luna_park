# frozen_string_literal: false

require 'logger'
require 'forwardable'
require 'luna_park/extensions/severity_levels'
require 'luna_park/notifiers/tagged_log/options'
require 'luna_park/notifiers/tagged_log/tagged_formatter'

module LunaPark
  module Notifiers
    module TaggedLog
      include Extensions::SeverityLevels
      extend Forwardable

      SEVERITY_LEVELS = {
        unknown: Logger::Severity::UNKNOWN,
        fatal: Logger::Severity::FATAL,
        error: Logger::Severity::ERROR,
        warning: Logger::Severity::WARN,
        info: Logger::Severity::INFO,
        debug: Logger::Severity::DEBUG
      }.freeze

      private_constant :SEVERITY_LEVELS

      def_delegators :formatter, :push_tags, :clear_tags!
      attr_accessor :output

      module Formatter
        def call(severity, timestamp, progname, msg)
          super(severity, timestamp, progname, msg, tags_text)
        end

        def tagged(*tags)
          new_tags = push_tags(*tags)
          yield self
        ensure
          pop_tags(new_tags.size)
        end

        def push_tags(*tags)
          tags.flatten!
          tags.reject! { |t| t.respond_to?(:empty?) ? !!t.empty? : !t }
          current_tags.concat tags
          tags
        end

        def pop_tags(size = 1)
          current_tags.pop(size)
        end

        def clear_tags!
          current_tags.clear
        end

        def current_tags
          thread_key = @thread_key ||= "tagged_log_tag_store_tags:#{object_id}"
          Thread.current[thread_key] ||= []
        end

        def tags_text
          current_tags.join(' ').strip
        end
      end

      def tagged(*tags)
        if block_given?
          formatter.tagged(*tags) { yield self }
        else
          logger = LunaPark::Notifiers::TaggedLog.new(
            output, **formatter.config.to_h
          )
          logger.push_tags(*formatter.current_tags, *tags)
          logger
        end
      end

      def post(msg, lvl: :error, **details)
        severity = severity(lvl)
        message = { original_msg: msg, details: details }
        add severity, message
      end

      def severity(lvl)
        severity = SEVERITY_LEVELS[lvl]
        raise ArgumentError, "Unknown level #{lvl}" if severity.nil?

        severity
      end

      def self.new(output = $stdout, **options)
        config = LunaPark::Notifiers::TaggedLog::Options.wrap(options)

        logger = Logger.new(output)
        logger.formatter = LunaPark::Notifiers::TaggedLog::TaggedFormatter.new
        logger.formatter.config = config
        logger.formatter.extend(Formatter)
        logger.extend(self)
        logger.output = output
        logger.min_lvl = config.min_lvl
        logger
      end
    end
  end
end
