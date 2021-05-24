# frozen_string_literal: true

require 'luna_park/extensions/validatable'
require 'luna_park/errors'

module LunaPark
  module Forms
    ##
    # Form object represents blank document, required to filled right, and can be performed
    #
    # @example with default behavior
    #  class MyForm < LunaPark::Forms::SingleItem
    #    validation MyValidator # respond to .validate, #valid?, #errors, #valid_params
    #
    #    def perform(valid_params)
    #      "Performed #{valid_params[:foo]}"
    #    end
    #  end
    #
    #  form = MyForm.new({ foo: 'Foo', excess: 'Excess' })
    #
    #  if form.submit
    #    form.result # => 'Performed Foo'
    #  else
    #    form.errors # => { foo: ['is wrong'] }
    #  end
    #
    # @example without default behavior
    #  class MyForm < LunaPark::Forms::SingleItem
    #    validation MyValidator # respond to .validate, #valid?, #errors, #valid_params
    #  end
    #
    #  form = MyForm.new({ foo: 'Foo', excess: 'Excess' })
    #
    #  if form.submit
    #    form.result # => { foo: 'Foo' }
    #  else
    #    form.errors # => { foo: ['is wrong'] }
    #  end
    #
    class Simple
      include Extensions::Validatable

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
      def perform(valid_params)
        valid_params
      end
      # :nocov:
    end
  end
end
