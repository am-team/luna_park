# frozen_string_literal: true

module LunaPark
  module Handlers
    class Simple
      # :nocov:
      def self.catch
        raise Errors::AbstractMethod
      end
      # :nocov:
    end
  end
end
