# frozen_string_literal: true

module LunaPark
  module Gateways
    module Http
      class RestClient
        attr_reader :default_handler

        def initialize(handler: Handlers::Default)
          @handler_klass = handler
        end

        def request(title, options: {}, **request_params)
          self.class.send_request title: title,
                                  request: Requests::Base.new(request_params),
                                  handler: handler(options)
        end

        def json_request(title, options: {}, **request_params)
          self.class.send_request title: title,
                                  request: Requests::Json.new(request_params),
                                  handler: handler(options)
        end

        # @example
        #   # Gemfile
        #   gem 'rest-client'
        #
        #   # ./app.rb
        #   module App
        #     include LunaPark::Gateways::Http
        #
        #     request = Requests::Base.new( method: :post, url: 'http://example.com', body: 'ping')
        #     handler = Handlers::Default.new(skip_errors: [404])
        #
        #     RestClient.send_request('Ping-pong', request: request, handler: handler)
        #   end
        # @param title [String] custom message
        # @param request [Requests::Base, Requests::Json] request object
        # @param handler [Handlers::Default] handler of http exceptions
        # @return [::RestClient::Response]
        def self.send_request(title:, request:, handler:)
          ::RestClient::Request.execute(request.to_h)
        rescue ::RestClient::Exceptions::Timeout
          handler.timeout_error(title, request: request)
        rescue ::RestClient::Exception => e
          handler.error(title, request: request, response: e.response)
        end

        private

        attr_reader :handler_klass

        def handler(params)
          handler_klass.new params
        end
      end
    end
  end
end
