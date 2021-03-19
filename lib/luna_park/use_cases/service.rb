# frozen_string_literal: true

require 'luna_park/extensions/callable'
require 'luna_park/extensions/has_errors'

module LunaPark
  module UseCases
    class Service
      extend  Extensions::Callable
      include Extensions::HasErrors
    end
  end
end
