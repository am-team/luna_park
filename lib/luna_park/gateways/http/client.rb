module LunaPark
  module Gateways
    module Http
      class Client
        attr_reader :default_handler

        def initialize(handler: Handlers::Rest.new)
          @default_handler = handler
        end

        def request(title, handler: nil, **request_params)
          self.class.send_request title:   title,
                                  request: Requests::Base.new(request_params),
                                  handler: handler || default_handler
        end

        def json_request(title, handler: nil, **request_params)
          self.class.send_request title:   title,
                                  request: Requests::Json.new(request_params),
                                  handler: handler || default_handler
        end


        def self.send_request(title:, request:, handler:)
          handler.catch(title: title, request: request) { RestClient::Request.execute(request.to_h) }
        end
      end
    end
  end
end