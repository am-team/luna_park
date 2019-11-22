# frozen_string_literal: true

module LunaPark
  module Gateways
    module Http
      module Errors
        module Default
          class Diagnostic < StandardError
            attr_reader :title, :request, :response

            def initialize(title, request:, response:)
              @response = response
              @title    = title
              @request  = request
            end

            def message
              "RequestError (code: #{request.status}) on request #{title}"
            end
          end

          class Timeout < StandardError
            attr_reader :title, :request

            def initialize(title, request:)
              @title   = title
              @request = request
            end

            def message
              "TimeoutError on request #{title}"
            end
          end
        end
      end
    end
  end
end
