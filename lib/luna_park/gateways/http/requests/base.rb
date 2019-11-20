# frozen_string_literal: true

module LunaPark
  module Gateways
    module Http
      module Requests
        class Base
          OPEN_TIMEOUT = 10
          READ_TIMEOUT = 10

          attr_reader :method, :url, :body, :headers, :read_timeout, :open_timeout

          # rubocop:disable Metrics/ParameterLists
          def initialize(method: :post, url:, body: nil, headers: nil, read_timeout: READ_TIMEOUT, open_timeout: OPEN_TIMEOUT)
            @method = method
            @url = url
            @body = body
            @headers = headers
            @read_timeout = read_timeout
            @open_timeout = open_timeout
          end
          # rubocop:enable Metrics/ParameterLists

          def to_h
            {
              method: method,
              url: url,
              payload: body,
              headers: headers,
              read_timeout: read_timeout,
              open_timeout: open_timeout,
            }
          end
        end
      end
    end
  end
end