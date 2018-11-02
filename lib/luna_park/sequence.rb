# frozen_string_literal: true

module LunaPark
  class Sequence
    include Extensions::Attributable

    attr_reader :fail_message

    def initialize(attrs = {})
      set_attributes(attrs)
      @fail = false
      @fail_message = ''
    end

    def call
      raise NotImplementedError
    end

    def data
      raise NotImplementedError
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
        new(*attrs).call
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
