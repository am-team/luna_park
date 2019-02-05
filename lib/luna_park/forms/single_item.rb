# frozen_string_literal: true

module LunaPark
  module Forms
    ##
    # Form object represents blank document, required to filled right, and can be performed
    #
    # @example
    #  class MyForm < LunaPark::Forms::SingleItem
    #    validator MyValidator # respond to .validate, #valid?, #validation_errors, #valid_params
    #
    #    def perform
    #      'PerformResult'
    #    end
    #
    #    def foo_bar=(foo_bar)
    #      @foo_bar = foo_bar
    #    end
    #  end
    #
    #  form = MyForm.new({ foo_bar: {} })
    #
    #  if form.submit
    #    form.result # => 'PerformResult'
    #  else
    #    form.errors # => { foo_bar: ['is wrong'] }
    #  end
    class SingleItem
      include Extensions::Attributable
      include Extensions::Validateable

      attr_reader :result

      def initialize(params = {})
        @params = params
      end

      def submit
        if valid?
          fill!
          perform!
          true
        else false
        end
      end

      alias errors validation_errors

      private

      attr_reader :params

      def fill!
        set_attributes valid_params
      end

      def perform!
        @result = perform
      end

      # :nocov:

      # @abstract
      def perform
        raise Errors::AbstractMethod
      end
      # :nocov:
    end
  end
end
