# frozen_string_literal: true

module LunaPark
  # add description
  module Serializers
    class Simple
      def initialize(object)
        @object = object
      end

      # :nocov:
      def to_h
        raise Errors::AbstractMethod
      end
      # :nocov:

      def to_json
        JSON.dump(to_h)
      end

      private

      attr_reader :object
    end
  end
end
