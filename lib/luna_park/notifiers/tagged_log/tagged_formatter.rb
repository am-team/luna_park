# frozen_string_literal: false

require 'json'

module LunaPark
  module Notifiers
    module TaggedLog
      class TaggedFormatter < Logger::Formatter
        attr_accessor :config

        def call(severity, timestamp, _, msg, tags = nil)
          payload = common_payload(severity, timestamp, tags)
            .merge(msg_payload(msg[:original_msg]))

          deep_merge!(payload, details_payload(msg[:details]))

          ::JSON.generate(payload) << "\n"
        end

        private

        def details_payload(hash)
          details = hash.delete(:details)
          payload = { details: hash }
          deep_merge!(payload, { details: details }) unless details.nil?
          payload
        end

        def common_payload(severity, timestamp, tags)
          {
            tags: [@config.default_tag, tags].join(' ').strip,
            app: @config.app,
            app_env: @config.app_env,
            instance: @config.instance,
            created_at: timestamp.iso8601(3),
            ok: !%w[FATAL ERROR].include?(severity)
          }
        end

        def msg_payload(msg)
          case msg
          when ::Exception
            error_payload(msg)
          when Hash
            hash_payload(msg)
          else
            { details: { message: try_to_json(msg) } }
          end
        end

        def error_payload(e)
          error_hash = {
            class: e.class,
            message: e.message
          }
          error_hash.merge!(backtrace: "\n" + e.backtrace.join("\n") + "\n") if e.backtrace
          payload = {
            error: error_hash,
            ok: false
          }
          payload.merge!(details: e.details) if e.respond_to?(:details)
          payload
        end

        def hash_payload(msg)
          details = msg.delete(:details)
          payload = { details: msg }
          deep_merge!(payload, { details: details }) unless details.nil?
          payload
        end

        def try_to_json(str)
          ::JSON.parse(str)
        rescue ::JSON::ParserError
          str
        end

        def deep_merge!(hash, other_hash)
          hash.merge!(other_hash) do |_, this_val, other_val|
            if this_val.is_a?(Hash) && other_val.is_a?(Hash)
              deep_merge!(this_val, other_val)
            else
              other_val
            end
          end
        end
      end
    end
  end
end
