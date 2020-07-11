# frozen_string_literal: true

require 'luna_park/errors/adaptive'

module LunaPark
  module Errors
    class Processing < Adaptive
      DEFAULT_ACTION = :catch

      # The expected behavior of the error handler if an error
      # instance of this class is raised
      #
      # - :stop - stop the application and don't give any feedback (
      #   Something happened, but the user doesn't know what it is )
      # - :catch - send a fail message to end-user
      # - :raise - work like StandardError, and it was handled on application level
      #
      # @return [Symbol] action
      #
      # @example action is undefined
      #   error = LunaPark::Errors::Adaptive
      #   error.action # => :catch
      #
      # @example action is defined in class
      #   class ExampleError < LunaPark::Errors::Adaptive
      #     on_error action: :catch
      #   end
      #   error = ExampleError.new
      #   error.action # => :catch
      #
      # @example action defined in an instance
      #   error = ExampleError.new nil, action: :stop
      #   error.action #=> :stop
      def action
        @action ||= self.class.default_action
      end
    end
  end
end
