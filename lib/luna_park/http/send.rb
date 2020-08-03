# frozen_string_literal: true

# frozen_string_literal: true вот с этой табор

require 'rest-client'
require 'luna_park/extensions/callable'
require 'luna_park/errors/http'
require 'luna_park/http/response'

module LunaPark
  module Http
    # Send {LunaPark::Http::Request} and get {LunaPark::Http::Response}.
    #
    # This service, in fact, works as an adapter for the {https://github.com/rest-client/rest-client RestClient} gem.
    # If you want to remove dependence on RestClient,
    # you should rewrite Send class.
    #
    # Instead of using these service directly, better use the request method {LunaPark::Http::Request#call}.
    # Which freeze request and define {LunaPark::Http::Request#sent_at} timestamp.
    class Send
      extend Extensions::Callable

      # Define new Send service
      #
      # @param [LunaPark::Http::Request] original_request -  the request which you would like to send.
      def initialize(original_request)
        @original_request = original_request
      end

      # Send defined request. Always return response even if the response is not successful.
      #
      # @example success response
      #   LunaPark::Http::Send.new(request).call #=> <LunaPark::Http::Response @code=200
      #     # @body="{"version":1,"data":"Hello World!"}" @headers={:content_type=>"application/json",
      #     # :connection=>"close", :server=>"thin"} @cookies={}>
      #
      # @example server is unavailable
      #   LunaPark::Http::Send.new(request).call # => <LunaPark::Http::Response @code=503
      #     # @body="" @headers={} @cookies={}>
      #
      # @return [LunaPark::Http::Response]
      def call
        rest_request = build_rest_request(original_request)
        rest_response = rest_request.execute
        build_original_response(rest_response)
      rescue Errno::ECONNREFUSED               then build_unavailable_response
      rescue ::RestClient::Exceptions::Timeout then build_timeout_response
      rescue ::RestClient::Exception => e      then build_original_response(e.response)
      end

      # Send defined request. If response is not successful the method raise {LunaPark::Errors::Http}
      #
      # @example success response
      #   LunaPark::Http::Send.new(request).call #=> <LunaPark::Http::Response @code=200
      #     # @body="{"version":1,"data":"Hello World!"}" @headers={:content_type=>"application/json",
      #     # :connection=>"close", :server=>"thin"} @cookies={}>
      #
      # @example server is unavailable
      #   LunaPark::Http::Send.new(request).call # => raise LunaPark::Errors::Http
      #
      # @raise [LunaPark::Errors::Http] on bad response, timeout or server is unavailable
      # @return [LunaPark::Http::Response]
      def call!
        call.tap do |response|
          raise Errors::Http.new(response.status, response: response) unless response.success?
        end
      end

      private

      attr_reader :original_request

      def build_rest_request(request)
        RestClient::Request.new(
          url: request.url,
          method: request.method,
          payload: request.body,
          headers: request.headers,
          open_timeout: request.open_timeout,
          read_timeout: request.read_timeout
        )
      end

      def build_original_response(rest_response)
        Response.new(
          body: rest_response.body,
          code: rest_response.code,
          headers: rest_response.headers,
          cookies: rest_response.cookies,
          request: original_request
        )
      end

      def build_timeout_response
        Response.new(code: 408, request: original_request)
      end

      def build_unavailable_response
        Response.new(code: 503, request: original_request)
      end
    end
  end
end
