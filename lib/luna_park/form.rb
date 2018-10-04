# frozen_string_literal: true

module LunaPark
  class Form
    class LogicError < StandardError; end

    attr_reader :result

    def initialize(params = {})
      @params = params
      @result = nil
    end

    def complete!
      if validate! && valid?
        fill!
        persist!
      else false
      end
    end

    def errors
      validation_result.errors || {}
    end

    private

    attr_reader :params

    def validation_result
      @validation_result ||= self.class.validate(params)
    end

    def valid?
      validation_result.success?
    end

    def validate!
      @validation_result = nil
      validation_result
    end

    def valid_params
      (valid? && validation_result.output) || {}
    end

    def fill!
      valid_params['attributes'].each do |attr, value|
        send("#{attr}=", value)
      end
    end

    def persist!
      raise NoMethodError
    end

    class << self
      def validator(klass)
        @_validator = klass
      end

      def validate(params)
        @_validator.validate(params) if has_validator?
      end

      def has_validator?
        @_validator
      end
    end
  end
end