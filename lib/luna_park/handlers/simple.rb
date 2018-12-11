# frozen_string_literal: true

module LunaPark
  module Handlers
    class Simple
      def self.catch
        raise Errors::AbstractMethod
      end
    end
  end
end
