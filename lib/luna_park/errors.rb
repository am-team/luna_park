# frozen_string_literal: true

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
