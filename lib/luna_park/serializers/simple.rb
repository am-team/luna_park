# frozen_string_literal: true

module LunaPark
  # add description
  module Serializers
    class Simple
      def initialize(object)
        @object = object
      end

      # :nocov:

      # @abstract
      def to_h
        raise Errors::AbstractMethod
      end
      # :nocov:

      def to_json(opts = nil)
        JSON.generate(to_h, opts)
      end

      private

      attr_reader :object
    end
  end
end
