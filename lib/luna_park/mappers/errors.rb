# frozen_string_literal: true

require 'luna_park/errors'

module LunaPark
  module Mappers
    module Errors
      class NotArray < ArgumentError
        def initialize(message = nil, input:, **_)
          super message || "input MUST be an Array, but given #{input.class} `#{input.inspect}`"
        end
      end
    end
  end
end
