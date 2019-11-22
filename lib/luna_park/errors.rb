# frozen_string_literal: true

require 'luna_park/extensions/exceptions/substitutive'

module LunaPark
  module Errors
    class NotConfigured  < StandardError; end
    class AbstractMethod < StandardError; end
    class Unwrapable     < TypeError; end

    class Processing < RuntimeError
      extend Extensions::Exceptions::Substitutive
    end
  end
end
