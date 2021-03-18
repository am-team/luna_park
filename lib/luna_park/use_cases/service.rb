# frozen_string_literal: true

require 'luna_park/extensions/has_errors'

module LunaPark
  module UseCases
    class Service
      extend Extensions::Callable
      extend Extensions::HasErrors
    end
  end
end
