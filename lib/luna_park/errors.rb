# frozen_string_literal: true

require 'luna_park/errors/processing'

module LunaPark
  module Errors
    class NotConfigured   < StandardError; end
    class AbstractMethod  < StandardError; end
    class Unwrapable      < TypeError; end

    class RepositoryError < StandardError; end
    class NotFound        < RepositoryError; end
  end
end
