# frozen_string_literal: true

module LunaPark
  class Service
    module Errors
      class Processing < StandardError; end
    end

    def call
      raise NoMethodError
    end

    def self.call(*args)
      self.new(*args).call
    end
  end
end