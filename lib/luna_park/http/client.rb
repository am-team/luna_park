# frozen_string_literal: true

require 'luna_park/http/request'
require 'luna_park/http/response'
require 'luna_park/http/send'

module LunaPark
  module Http
    # Client are useful for organize a repository where the source of the date is the http-server,
    # you should to inherit from this class. And interpret all the necessary endpoints as logical methods.
    #
    # <b>For example</b>:
    # You have api endpoint, which get list of all users (GET http://api.example.com/users),
    # as part of json api. Then you should define `Client` in your `Users` domain and
    # define `all` method which get list of all users.
    #
    #   module Users
    #     class Client < LunaPark::Http::Client
    #       def all
    #         response = get! json_request(
    #             title: 'Get users',
    #             url: 'http://api.example.com/users',
    #           )
    #         response.json_parse || []
    #       end
    #     end
    #   end
    #
    # == Handle errors in the simple way
    #
    # But how to handle http errors? You have two ways: simple and flexible. In first case
    # you realize all request with bang-methods (get!, post!, put!, etc.). And if something
    # went wrong client raise {LunaPark::Errors::Http} exception.
    #
    #   # Server is unavailable
    #   client = Users::Clients.new
    #   client.all # => raise LunaPark::Errors::Http (Service Unavailable)
    #   # And your clients will see server error.
    #
    # == Handle errors in the flexible way
    #
    # But if you have different cases based on different HTTP codes, you should choose
    # flexible way.
    #
    # <b>For example</b>:
    # You develop application for a delivery service. And you should realize Orders domain.
    # The Orders domain makes payment requests to the microservice responsible for transactions.
    #
    # Transactions microservice on payment endpoint has four uses cases, based on Http codes:
    # - 201 - payment is successfully created.
    # - 400 - request, has wrong structure, validation error.
    # - 422 - business logic error (small balance for example).
    #     {"error":"Not enough funds in your account"}
    # - 500 - server error
    # Your transaction service client should process this code is:
    # - 200 - return true
    # - 422 - forward business logic error message to your customer
    # - in others ways show server error to your client, and you your should notify developers about that.
    #
    # @example
    #   module Payments
    #     class Client < LunaPark::Http::Client
    #       def create(account:, money:)
    #         response = post json_request(
    #           title: 'Make payment for order',
    #           url: 'http://api.transactions.example.com/payments',
    #           body: {account: account, money: money}
    #         )
    #         case response.code
    #         when 200 then true
    #         when 422 then raise Error::Processing.new(response.body.parse_json(payload_key: error), action: :catch)
    #         else raise Errors::Http.new(response.status, notify: true, response: response)
    #         end
    #       end
    #     end
    #   end
    #
    #   # In your checkout scenario, payment is being made
    #   module Orders
    #     module Scenarios
    #       class Checkout < LunaPark::Interactors::Scenario
    #         def call!
    #           # ...
    #           payments.create(account: 42, money: Values::Money.new(100, :usd))
    #           # ...
    #         end
    #       end
    #     end
    #   end
    #
    #   # In endpoint,  if the client does not have enough money on his balance
    #   checkout.call
    #   checkout.success?     # => false
    #   checkout.fail_message # => "Not enough funds in your account"
    class Client
      PLAIN_HEADERS = { 'Content-Type': 'application/www-form-urlencoded' }.freeze
      JSON_HEADERS  = { 'Content-Type': 'application/json' }.freeze

      # Build plain request
      #
      # @param [String] title business description for request
      # @param [String] url request url
      # @param [String,Symbol] method http method (get, post, etc)
      # @param [NilClass,String] body http request body
      # @param [Hash] headers http headers
      #
      # @example
      #   request = plain_request(
      #     title: 'get users list',
      #     url: 'http://api.example.com/users'
      #   )
      #
      #   request # => <LunaPark::Http::Request @title="get users list"
      #     # @url="http://api.example.com/users" @method="get"
      #     # @headers="{:"Content-Type"=>"application/www-form-urlencoded"}"
      #     # @body="" @sent_at="">
      #
      # @return [LunaPark::Http::Request]
      def plain_request(title:, url:, method: :get, body: nil, headers: {})
        plain_headers = PLAIN_HEADERS.dup.merge(headers)

        Request.new(
          title: title,
          url: url,
          method: method,
          body: body,
          headers: plain_headers
        )
      end

      # Build plain request. Body will convert to json format automatically.
      #
      # @param [String] title business description for request
      # @param [String] url request url
      # @param [String,Symbol] method http method (get, post, etc)
      # @param [NilClass,String,Hash] body http request body
      # @param [Hash] headers http headers
      #
      # @example
      #   request = json_request(
      #     title: 'Ping pong',
      #     url: 'http://api.example.com/ping',
      #     body: {message: 'ping'}
      #   )
      #
      #   request # => <LunaPark::Http::Request @title="Ping pong"
      #     # @url="http://api.example.com/ping" @method="get"
      #     # @headers="{:"Content-Type"=>"application/json"}"
      #     # @body="{"message":"ping"}" @sent_at="">
      #
      # @return [LunaPark::Http::Request]
      def json_request(title:, url:, method: :get, body: nil, headers: {})
        json_headers = JSON_HEADERS.dup.merge(headers)
        json_body    = body ? JSON.generate(body) : nil

        Request.new(
          title: title,
          url: url,
          method: method,
          body: json_body,
          headers: json_headers
        )
      end

      # Send GET request. Always return response even if the response is not successful.
      #
      # @example success response
      #   get json_request(title: 'Hi world', url: 'http://example.com/hi')
      #     # => <LunaPark::Http::Response @code=200
      #     #   @body="{"version":1,"data":"Hello World!"}" @headers={:content_type=>"application/json",
      #     #   :connection=>"close", :server=>"thin"} @cookies={}>
      #
      # @example server is unavailable
      #   get json_request(title: 'Hi world', url: 'http://example.com/hi')
      #     # => <LunaPark::Http::Response @code=503
      #     #   @body="" @headers={} @cookies={}>
      #
      # @return [LunaPark::Http::Response]
      def get(request)
        request.method = :get
        request.call
      end

      # Send POST request. Always return response even if the response is not successful.
      # @see #get
      def post(request)
        request.method = :post
        request.call
      end

      # Send PUT request. Always return response even if the response is not successful.
      # @see #get
      def put(request)
        request.method = :put
        request.call
      end

      # Send PATCH request. Always return response even if the response is not successful.
      # @see #get
      def patch(request)
        request.method = :patch
        request.call
      end

      # Send DELETE request. Always return response even if the response is not successful.
      # @see #get
      def delete(request)
        request.method = :delete
        request.call
      end

      # Send GET request. Raise {LunaPark::Errors::Http} on bad response.
      #
      # @example success response
      #   get json_request(title: 'Hi world', url: 'http://example.com/hi')
      #     # => <LunaPark::Http::Response @code=200
      #     #   @body="{"version":1,"data":"Hello World!"}" @headers={:content_type=>"application/json",
      #     #   :connection=>"close", :server=>"thin"} @cookies={}>
      #
      # @example server is unavailable
      #   get json_request(title: 'Hi world', url: 'http://example.com/hi')
      #     # => raise LunaPark::Errors::Http
      #
      # @raise [LunaPark::Errors::Http] on bad response, timeout or server is unavailable
      # @return [LunaPark::Http::Response]
      def get!(request)
        request.method = :get
        request.call!
      end

      # Send POST request. Raise {LunaPark::Errors::Http} on bad response.
      # @see #get!
      def post!(request)
        request.method = :post
        request.call!
      end

      # Send PUT request. Raise {LunaPark::Errors::Http} on bad response.
      # @see #get!
      def put!(request)
        request.method = :put
        request.call!
      end

      # Send PATCh request. Raise {LunaPark::Errors::Http} on bad response.
      # @see #get!
      def patch!(request)
        request.method = :patch
        request.call!
      end

      # Send DELETE request. Raise {LunaPark::Errors::Http} on bad response.
      # @see #get!
      def delete!(request)
        request.method = :delete
        request.call!
      end
    end
  end
end
