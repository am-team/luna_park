# frozen_string_literal: true

require 'luna_park/extensions/exceptions/substitutive'

module LunaPark
  module Errors
    class JsonParse < System
      extend Extensions::Exceptions::Substitutive
    end
  end
end
