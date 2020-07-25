# frozen_string_literal: true

require 'luna_park/extensions/exceptions/substitutive'

module LunaPark
  module Mappers
    class Codirectional < Simple
      module Errors
        class NotHashGiven < StandardError
          extend LunaPark::Extensions::Exceptions::Substitutive

          attr_reader :path, :object

          def initialize(msg, path:, object:)
            @path   = path
            @object = object
            super(msg || build_message)
          end

          def build_message
            "At path #{path.map(&:inspect).join(', ')} MUST be a Hash, but is a #{object.class}: #{object.inspect}"
          end
        end
      end
    end
  end
end
