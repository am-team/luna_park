# frozen_string_literal: true

module LunaPark
  module Gateways
    module Http
      module Errors
        # class Diagnostic < StandardError
        #   include ::Bugsnag::MetaData
        #
        #   attr_reader :title, :request, :response
        #
        #     @response = response
        #     @title    = title
        #     @request  = request
        #
        #     self.bugsnag_meta_data = {
        #       title: title,
        #       client_request: {
        #         url: request.url,
        #         method: request.method,
        #         headers: request.headers,
        #         body: try_parse(request.body)
        #       },
        #       client_response: {
        #         code: response&.code,
        #         headers: response&.headers,
        #         body: try_parse(response&.message)
        #       }
        #     }
        #   end
        #
        #   private
        #
        #   def try_parse(string)
        #     JSON.parse(string) if string
        #   rescue JSON::ParserError
        #     string
        #   end
        # end

        class Timeout < LunaPark::Errors::Adaptive
          include ::Bugsnag::MetaData

          attr_reader :title, :request

          def initialize(title, request:)
            msg = "Timeout error on `#{title}` request"
            request_data = {
              url: request.url,
              method: request.method,
              headers: request.headers,
              body: try_parse(request.body)
            }

            super(msg, notify: true, action: :raise, client_request: request_data)
          end

          private

          def try_parse(string)
            JSON.parse(string) if string
          rescue JSON::ParserError
            string
          end
        end
      end
    end
  end
end
