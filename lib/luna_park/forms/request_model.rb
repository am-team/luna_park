# frozen_string_literal: true

require 'luna_park/extensions/validatable'
require 'luna_park/errors'

module LunaPark
  module Forms
    ##
    # Form object represents blank document, required to filled right, and can be performed
    #
    # @example
    #  class MyForm < LunaPark::Forms::RequestModel
    #    include LunaPark::Extensions::Validatable::Dry
    #
    #    validator do
    #      required(:data).hash do
    #        required(:type) { filled? & eql?('users') }
    #        required(:attributes).hash do
    #          required(:name)  { filled? & str? }
    #          required(:email) { filled? & str? }
    #        end
    #      end
    #    end
    #
    #    attr :name,  String, :new
    #    attr :email, String, :new
    #
    #    def fill(valid_params)
    #      self.name  = valid_params[:data][:attributes][:name]
    #      self.email = valid_params[:data][:attributes][:email]
    #    end
    #  end
    #
    #  form = MyForm.new({ data: { type: 'users', attributes: { name: 'John', email: 'john@email.com' } } })
    #
    #  if form.submit
    #    form.name
    #    form.email
    #    MySequence.call(request_model: form) # ? MyScenario.call(form)
    #  else
    #    form.errors # => { foo_bar: ['is wrong'] }
    #  end
    class RequestModel
      include Extensions::Validatable
      include Extensions::Dsl::Attrubutes # ? Nested
      include Extensions::Attrubutable

      def initialize(params = {})
        @params = params
      end

      def submit
        if valid?
          fill(valid_params)
          true
        else false
        end
      end

      alias errors validation_errors

      private

      attr_reader :params

      def fill(valid_params)
        set_attributes(valid_params)
      end
    end
  end
end
