# frozen_string_literal: true

module LunaPark
  module Entities
    # add description
    # TODO: make it base for Nested
    class Simple
      include Extensions::Attributable

      def initialize(params = {})
        set_attributes(params)
      end
    end
  end
end
