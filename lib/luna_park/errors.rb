# frozen_string_literal: true

require 'luna_park/errors/base'
require 'luna_park/errors/system'
require 'luna_park/errors/business'

module LunaPark
  module Errors
    class NotConfigured   < System; end
    class AbstractMethod  < System; end
    class Unwrapable      < System; end

    class RepositoryError < System; end
    class NotFound        < RepositoryError; end
  end
end
