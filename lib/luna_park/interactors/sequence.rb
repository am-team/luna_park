# frozen_string_literal: true

module LunaPark
  module Interactors
    # add description
    class Sequence
      include Extensions::Attributable
      extend  Extensions::Callable

      attr_reader :fail_message

      INIT    = :initialized
      SUCCESS = :success
      FAILURE = :failure

      def initialize(attrs = {})
        set_attributes attrs
        @state          = INIT
        @fail_message   = nil
      end

      def call!
        execute
      end

      def call
        catch { call! }
        success?
      end

      def data
        returned_data if success?
      end

      def fail?
        @state == FAILURE
      end

      def success?
        @state == SUCCESS
      end

      class << self
        def call(*attrs)
          new(*attrs).tap(&:call)
        end
      end

      private

      def catch
        yield
        @state = SUCCESS
      rescue Errors::Processing => e
        @fail_message = e.message
        @state        = FAILURE
      end

      # :nocov:

      # @abstract
      def execute
        raise Errors::AbstractMethod
      end

      # @abstract
      def returned_data
        raise Errors::AbstractMethod
      end
      # :nocov:
    end
  end
end
