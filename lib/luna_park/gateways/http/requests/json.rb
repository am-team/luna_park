# frozen_string_literal: true

module LunaPark
  module Gateways
    module Http
      module Requests
        class Json < Base
          JSON_HEADERS = { 'Content-Type': 'application/json' }.freeze

          # rubocop:disable Metrics/ParameterLists,Metrics/LineLength
          def initialize(method: :post, url:, body: nil, headers: JSON_HEADERS, read_timeout: READ_TIMEOUT, open_timeout: OPEN_TIMEOUT)
            @method = method
            @url = url
            @body = JSON.generate(body)
            @headers = headers
            @read_timeout = read_timeout
            @open_timeout = open_timeout
          end
          # rubocop:enable Metrics/ParameterLists,Metrics/LineLength
        end
      end
    end
  end
end
