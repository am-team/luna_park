# frozen_string_literal: true

require 'luna_park/extensions/attributable'
require 'luna_park/extensions/wrappable'
require 'luna_park/errors'

module LunaPark
  module Values
    class Compound
      extend  Extensions::Wrappable
      include Extensions::Attributable

      def initialize(attrs = {})
        set_attributes attrs
      end

      # :nocov:

      # @abstract
      def ==(_other)
        raise Errors::AbstractMethod
      end
      # :nocov:
    end
  end
end
