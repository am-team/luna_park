# frozen_string_literal: true

module LunaPark
  module Extensions
    # add description
    module Attributable
      private

      def set_attributes(hash) # rubocop:disable Naming/AccessorMethodName
        hash.each { |k, v| send(:"#{k}=", v) }
      end
    end
  end
end
