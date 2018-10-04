# frozen_string_literal: true

module LunaPark
  class Sequence
    attr_reader :fail_message

    def initialize(attrs = {})
      self.attributes = attrs
      @fail = false
      @fail_message = ''
    end

    def call
      raise NoMethodError
    end

    def data
      raise NoMethodError
    end

    def attributes=(attrs)
      attrs.each do |k, v|
        send "#{k}=", v
      end
    end

    def fail?
      @fail
    end

    def success?
      !fail?
    end

    class << self
      def call(*attrs)
        self.new(*attrs).call
      end
    end

    private

    def catch
      yield
    rescue Service::Errors::Processing => e
      @fail = true
      @fail_message = e.message
    end
  end
end