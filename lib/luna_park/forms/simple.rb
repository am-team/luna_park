# frozen_string_literal: true

module LunaPark
  module Forms
    ##
    # Form object represents blank document, required to filled right, and can be performed
    #
    # @example
    #  class MyForm < LunaPark::Forms::SingleItem
    #    validation MyValidator # respond to .validate, #valid?, #errors, #valid_params
    #
    #    def perform(valid_params)
    #      "Performed #{valid_params[:foo_bar]}"
    #    end
    #  end
    #
    #  form = MyForm.new({ foo_bar: 'FooBar' })
    #
    #  if form.submit
    #    form.result # => 'Performed FooBar'
    #  else
    #    form.errors # => { foo_bar: ['is wrong'] }
    #  end
    class Simple
      include Extensions::Validateable

      attr_reader :result

      def initialize(params = {})
        @params = params
      end

      def submit
        if valid?
          perform!
          true
        else false
        end
      end

      alias errors validation_errors

      private

      attr_reader :params

      def perform!
        @result = perform(valid_params)
      end

      # :nocov:

      # @abstract
      def perform(_valid_params)
        raise Errors::AbstractMethod
      end
      # :nocov:
    end
  end
end
