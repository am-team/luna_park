# frozen_string_literal: true

module LunaPark
  module Extensions
    module Attributable
      private

      def set_attributes(hash)
        hash.each { |k, v| send(:"#{k}=", v) }
      end
    end
  end
end
