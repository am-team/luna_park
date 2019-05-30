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
        @data           = nil
      end

      # :nocov:

      # @abstract
      def call!
        raise Errors::AbstractMethod
      end
      # :nocov:

      def call
        catch { @data = call! }
        self
      end

      def data
        @data if success?
      end

      def fail?
        state == FAILURE
      end

      def success?
        state == SUCCESS
      end

      private

      attr_reader :state

      def catch
        yield
        @state = SUCCESS
      rescue Errors::Processing => e
        on_fail
        @fail_message = e.message
        @state        = FAILURE
      end

      def on_fail; end
    end
  end
end
