# frozen_string_literal: true

require 'luna_park/errors'

module LunaPark
  module Mappers
    module Errors
      class NotArray < LunaPark::Errors::System
        message { |d| "input MUST respond to #to_a, but given #{d[:input].class} `#{d[:input].inspect}`" }
      end
    end
  end
end
