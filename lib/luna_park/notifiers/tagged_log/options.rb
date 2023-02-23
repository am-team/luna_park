# frozen_string_literal: false

require 'luna_park/values/compound'

module LunaPark
  module Notifiers
    module TaggedLog
      class Options < LunaPark::Values::Compound
        attr_reader :default_tag, :app, :app_env, :instance, :min_lvl

        def initialize(attrs = {})
          logger_conf_error if config_incorrect?(attrs)
          set_attributes attrs
        end

        # @param [Notifiers::Log::Options, Hash] other
        # @return [Notifiers::Log::Options]
        def merge!(other)
          other = self.class.wrap(other)

          self.default_tag ||= other.default_tag
          self.app ||= other.app
          self.app_env ||= other.app_env
          self.instance ||= other.instance
          self.min_lvl ||= other.min_lvl

          self
        end

        def merge(other)
          dup.merge!(other)
        end

        def to_h
          {
            default_tag: default_tag,
            app: app,
            app_env: app_env,
            instance: instance,
            min_lvl: min_lvl
          }
        end

        private

        def config_incorrect?(attrs)
          return true if attrs.empty?

          !%i[default_tag app app_env instance min_lvl].all? do |required_key|
            attrs.keys.include?(required_key)
          end
        end

        def logger_conf_error
          raise ArgumentError, 'TaggedLog not properly configured'
        end

        def default_tag=(val)
          logger_conf_error if val.nil? || val.empty?
          logger_conf_error unless val.is_a?(String) || val.is_a?(Symbol)
          @default_tag = val
        end

        def app=(val)
          logger_conf_error if val.nil? || val.empty? || !val.is_a?(String)
          @app = val
        end

        def app_env=(val)
          logger_conf_error if val.nil? || val.empty? || !val.is_a?(String)
          @app_env = val
        end

        def instance=(val)
          logger_conf_error if val.nil? || val.empty? || !val.is_a?(String)
          @instance = val
        end

        def min_lvl=(val)
          logger_conf_error if val.nil? || val.empty?
          logger_conf_error unless val.is_a?(String) || val.is_a?(Symbol)
          @min_lvl = val.to_sym
        end
      end
    end
  end
end
