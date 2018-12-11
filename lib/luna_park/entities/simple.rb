# frozen_string_literal: true

module LunaPark
  module Entities
    # add description
    class Simple
      include Extensions::Attributable

      def initialize(params)
        set_attributes params
      end
    end
  end
end
