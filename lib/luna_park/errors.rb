# frozen_string_literal: true

module LunaPark
  module Errors
    class Processing     < StandardError; end
    class AbstractMethod < RuntimeError; end
    class Unwrapable     < ArgumentError; end
    class NotConfigured  < StandardError; end
  end
end
