# frozen_string_literal: true

module LunaPark
  # add description
  class Service
    module Errors
      class Processing < StandardError; end
    end

    def call
      raise NotImplementedError
    end

    def self.call(*args)
      new(*args).call
    end
  end
end
