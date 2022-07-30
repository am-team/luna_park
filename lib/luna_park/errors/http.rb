# frozen_string_literal: true

require 'luna_park/errors/system'
require 'luna_park/http/response'

module LunaPark
  module Errors
    class Http < System
      # Errors::Http must contain response
      #
      # @return LunaPark::Http::Response
      attr_reader :response

      # Create new error
      #
      # @param msg - Message text
      # @param notify - custom notify behaviour for the current instance of error (see #self.notify)
      # @param details - additional information to notifier
      #
      # @example without parameters
      #   error = Fatalism.new
      #   error.message     # => 'You cannot change your destiny'
      #   error.notify_lvl  # => :error
      #   error.notify?     # => true
      #
      # @example with custom parameters
      #   @error = Fatalism.new 'Forgive me Kuzma, my feet are frozen', notify: false
      #   error.message     # => 'Forgive Kuzma, my feet froze'
      #   error.notify_lvl  # => :error
      #   error.notify?     # => false
      def initialize(msg = nil, response:, notify: nil, **details)
        raise ArgumentError, 'Response should be Http::Response' unless response.is_a? LunaPark::Http::Response

        @response = response
        super msg, notify:, **details
      end

      # Return request which call this is error.
      def request
        response.request
      end

      # Formatted details
      # Resource does not found
      # @example Error details
      # Http::Error.new(request: request, something: 'important').details # => {
      #   #  title: 'Ping-pong',
      #   #  status: 'OK',
      #   #  request: {
      #   #    body: '{"message":"ping"}',
      #   #    method: :post,
      #   #    headers: {'Content-Type': 'application/json'},
      #   #    open_timeout: 10,
      #   #    read_timeout: 10,
      #   #    sent_at: nil,
      #   #    url: 'http://example.com/api/ping'
      #   #  },
      #   #  response: {
      #   #    body: '{"message":"pong"}',
      #   #    code: 200,
      #   #    headers: {'Content-Type': 'application/json'},
      #   #    cookies: {'Secret': 'dkmvc9saudj3cndsaosp'}
      #   #  },
      #   #  error_details: { something: 'important' }
      #   # }
      def details # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        {
          title: request.title,
          status: response.status,
          request: {
            method: request.method,
            url: request.url,
            open_timeout: request.open_timeout,
            read_timeout: request.read_timeout,
            sent_at: request.sent_at,
            headers: request.headers,
            body: request.body
          },
          response: {
            code: response.code,
            headers: response.headers,
            cookies: response.cookies,
            body: response.body
          },
          error_details: super
        }
      end
    end
  end
end
