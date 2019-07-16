# frozen_string_literal: true

require_relative '../errors'

module LunaPark
  module Handlers
    class Simple
      # :nocov:

      # @abstract
      def self.catch
        raise Errors::AbstractMethod
      end
      # :nocov:
    end
  end
end
