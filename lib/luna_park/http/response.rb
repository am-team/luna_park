# frozen_string_literal: true

require 'luna_park/errors'

module LunaPark
  module Http
    # Http response value object.
    class Response # rubocop:disable Metrics/ClassLength
      # List of descriptions http codes
      STATUSES = {
        # Informational response
        100 => 'Continue',
        101 => 'Switching Protocols',
        102 => 'Processing',                   # RFC '251'8 (WebDAV)
        103 => 'Early Hints',                  # RFC 8297

        # Success
        200 => 'OK',
        201 => 'Created',
        202 => 'Accepted',
        203 => 'Non-Authoritative Information',
        204 => 'No Content',
        205 => 'Reset Content',
        206 => 'Partial Content',
        207 => 'Multi-Status',                 # RFC '251'8 (WebDAV)
        208 => 'Already Reported',             # RFC '584'2
        226 => 'IM Used',                      # RFC 3229

        # Redirection
        300 => 'Multiple Choices',
        301 => 'Moved Permanently',
        302 => 'Found',
        303 => 'See Other',
        304 => 'Not Modified',
        305 => 'Use Proxy',
        307 => 'Temporary Redirect',
        308 => 'Permanent Redirect', # RFC 7538

        # Client error
        400 => 'Bad Request',
        401 => 'Unauthorized',
        402 => 'Payment Required',
        403 => 'Forbidden',
        404 => 'Not Found',
        405 => 'Method Not Allowed',
        406 => 'Not Acceptable',
        407 => 'Proxy Authentication Required',
        408 => 'Request Timeout',
        409 => 'Conflict',
        410 => 'Gone',
        411 => 'Length Required',
        412 => 'Precondition Failed',
        413 => 'Request Entity Too Large',
        414 => 'Request-URI Too Large',
        415 => 'Unsupported Media Type',
        416 => 'Request Range Not Satisfiable',
        417 => 'Expectation Failed',
        418 => 'I\'m a teapot',            # RFC '232'4
        422 => 'Unprocessable Entity',     # RFC '251'8 (WebDAV)
        423 => 'Locked',                   # RFC '251'8 (WebDAV)
        424 => 'Failed Dependency',        # RFC '251'8 (WebDAV)
        425 => 'No code',                  # WebDAV Advanced Collections
        426 => 'Upgrade Required',         # RFC '281'7
        428 => 'Precondition Required',
        429 => 'Too Many Requests',
        431 => 'Request Header Fields Too Large',
        449 => 'Retry with',                     # unofficial Microsoft
        452 => 'Unavailable For Legal Reasons',  # RFC 7225 The code 451 was chosen as a
        # reference to the novel Fahrenheit 451
        # Server errors
        500 => 'Internal Server Error',
        501 => 'Not Implemented',
        502 => 'Bad Gateway',
        503 => 'Service Unavailable',
        504 => 'Gateway Timeout',
        505 => 'HTTP Version Not Supported',
        506 => 'Variant Also Negotiates',         # RFC '229'5
        507 => 'Insufficient Storage',            # RFC '251'8 (WebDAV)
        509 => 'Bandwidth Limit Exceeded',        # unofficial
        510 => 'Not Extended',                    # RFC '277'4
        511 => 'Network Authentication Required'
      }.freeze

      # Response body
      #
      # @example json response
      #   response.body # => "{\"message\":\"pong\"}"
      #
      # @return String
      attr_reader :body

      # Http code, reference: {https://tools.ietf.org/html/rfc7231 rfc7231}
      #
      # @example success response
      #   response.code # => 200
      #
      # @return Integer
      attr_reader :code

      # Headers of http response
      #
      # @example json response
      #   response.headers # => { 'Content-Type': 'application/json' }
      #
      # @return Hash
      attr_reader :headers

      # Hash of cookies
      #
      # @example secret keys
      #   response.cookies # => {'secret' => '6f7a8459e4330122cac2b9752506a813610b814d'}
      #
      # @return Hash
      attr_reader :cookies

      # The request that actually initializes the current response
      #
      # @example
      #   request = Request.new(
      #     title: 'Get users list',
      #     method: :get,
      #     url: 'http://example.com/users'
      #   )
      #   response = request.call
      #   response.request === request # => true
      #   response.request # => "<LunaPark::Http::Request @title=\"Get users\"
      #                    #       @url=\"http://localhost:8080/get_200\" @method=\"get\"
      #                    #       @headers=\"{}\" @body=\"\" @sent_at=\"\">"
      #
      # @return LunaPark::Http::Response
      attr_reader :request

      # Create new response
      #
      # @param [LunaPark::Http::Request] request
      # @param [Integer] code
      # @param [String] body
      # @param [Hash] headers
      # @param [Hash] cookies
      def initialize(request:, code:, body: '', headers: {}, cookies: {})
        @request = request
        @code    = Integer(code)
        @body    = String(body)
        @headers = Hash(headers)
        @cookies = Hash(cookies)
      end

      # @example inspect get users index request
      #   request = LunaPark::Http::Request.new(
      #     title: 'Get users',
      #     method: :get,
      #     url: 'http://localhost:8080/get_200'
      #   )
      #
      #   response = LunaPark::Http::Request.new(
      #     code: 200,
      #     body: "{\"users\":[{\"name\":\"john\"}]",
      #     headers: {'Content-Type': 'application/json'}
      #   )
      #
      #   request.inspect # => "<LunaPark::Http::Request @title=\"Get users\"
      #                   #  @url=\"http://localhost:8080/get_200\" @method=\"get\"
      #                   #  @headers=\"{}\" @body=\"\" @sent_at=\"\">"
      #
      # @return [String]
      def inspect
        "<#{self.class.name} @code=#{code} @body=\"#{body}\" @headers=#{headers} @cookies=#{cookies}>"
      end

      # Check this response code is 1xx
      #
      # @example response status - `Continue`
      #   response.code                    # => 100
      #   response.informational_response? # => true
      #
      # @example response status - `Success`
      #   response.code                    # => 200
      #   response.informational_response? # => false
      #
      # @return [Boolean]
      def informational_response?
        (100..199).cover?(code)
      end

      # Check this response code is 2xx
      #
      # @example response status - `Success`
      #   response.code     # => 200
      #   response.success? # => true
      #
      # @example response status - `Continue`
      #   response.code     # => 100
      #   response.success? # => false
      #

      # @return [Boolean]
      def success?
        (200..299).cover?(code)
      end

      # Check this response code is 3xx
      #
      # @example response status - `Permanent Redirect`
      #   response.code         # => 308
      #   response.redirection? # => true
      #
      # @example response status - `Success`
      #   response.code         # => 200
      #   response.redirection? # => false
      #
      # @return [Boolean]
      def redirection?
        (300..399).cover?(code)
      end

      # Check this response code is 4xx
      #
      # @example response status - `Unprocessable Entity`
      #   response.code          # => 422
      #   response.client_error? # => true
      #
      # @example response status - `Success`
      #   response.code          # => 200
      #   response.client_error? # => false
      #
      # @return [Boolean]
      def client_error?
        (400..499).cover?(code)
      end

      # Check this response code is 5xx
      #
      # @example response status - `Internal Server Error`
      #   response.code          # => 500
      #   response.server_error? # => true
      #
      # @example response status - `Success`
      #   response.code          # => 200
      #   response.server_error? # => false
      #
      # @return [Boolean]
      def server_error?
        (500..599).cover?(code)
      end

      # Return response code type. It can be
      # - :informational_response - for response with 1xx code
      # - :success - for response with 2xx code
      # - :redirection - for response with 3xx code
      # - :client_error - for response with 4xx code
      # - :server_error - for response with 5xx code
      #
      # @example success response
      #   response.code # => 200
      #   response.type # => :success
      #
      # @return [Symbol]
      def type
        case code
        when 100..199 then :informational_response
        when 200..299 then :success
        when 300..399 then :redirection
        when 400..499 then :client_error
        when 500..599 then :server_error
        else :unknown
        end
      end

      # Describes what the code means in a human-readable format.
      #
      # @example when the object is successfully created
      #   response.code # => 201
      #   response.code # => 'Created'
      #
      # @example when the server is down
      #   response.code # => 503
      #   response.code # => 'Service Unavailable'
      def status
        STATUSES[code] || 'Unknown'
      end

      # Try to parse this response body from JSON format. If body
      # doesn`t consists expected JSON format, you catch {Errors::JsonParse}.
      # Also you can get only payload data if define payload_key.
      #
      # @param [String, Symbol] payload_key - key of payload data
      # @param [Boolean] stringify_keys - output hash should
      #
      # @example parse from json whole data
      #   response.body # => "{\"version\": 1, \"data\":{\"message\":\"pong\"}}"
      #   response.json_parse! # => {version: 1, data: { message: 'pong' }}
      #
      # @example get only payload data
      #   response.body # => "{\"version\": 1, \"data\":{\"message\":\"pong\"}}"
      #   response.json_parse! payload_key: :data # => { message: 'pong' }
      #
      # @example parse from json whole data with string keys
      #   response.body # => "{\"version\": 1, \"data\":{\"message\":\"pong\"}}"
      #   response.json_parse! stringify_keys: true # => {'version' => 1, 'data' => { 'message' => 'pong' }}
      #
      # @example get data from non-json body data
      #   response.body # => "pong"
      #   response.json_parse! # => raise Errors::JsonParse
      #
      # @return [Hash, String]
      def json_parse!(payload_key: nil, stringify_keys: false)
        data = JSON.parse(body, symbolize_names: !stringify_keys)
        return data unless payload_key

        payload_key = stringify_keys ? payload_key.to_s : payload_key.to_sym
        data.fetch(payload_key)
      rescue KeyError, JSON::ParserError
        raise Errors::JsonParse
      end

      # Try to parse this response body from JSON format. If body
      # doesn`t consists expected JSON format, you get nil.
      # Also you can get only payload data if define payload_key.
      #
      # @param [String, Symbol] payload_key - key of payload data
      # @param [Boolean] stringify_keys - output hash should
      #
      # @example parse from json whole data
      #   response.body # => "{\"version\": 1, \"data\":{\"message\":\"pong\"}}"
      #   response.json_parse! # => {version: 1, data: { message: 'pong' }}
      #
      # @example get only payload data
      #   response.body # => "{\"version\": 1, \"data\":{\"message\":\"pong\"}}"
      #   response.json_parse! payload_key: :data # => { message: 'pong' }
      #
      # @example parse from json whole data with string keys
      #   response.body # => "{\"version\": 1, \"data\":{\"message\":\"pong\"}}"
      #   response.json_parse! stringify_keys: true # => {'version' => 1, 'data' => { 'message' => 'pong' }}
      #
      # @example get data from non-json body data
      #   response.body # => "pong"
      #   response.json_parse! # => nil
      #
      # @return [Hash, String, nil]
      def json_parse(payload_key: nil, stringify_keys: false)
        json_parse!(payload_key: payload_key, stringify_keys: stringify_keys)
      rescue Errors::JsonParse
        nil
      end

      # @example
      #   request.to_h # => {
      #     :code=>200,
      #     :body=>"John Doe, Marry Ann",
      #     :headers=>{}, :cookies=>{},
      #     :request=>{
      #       :title=>"Get users",
      #       :method=>:get,
      #       :url=>"http://localhost:8080/get_200",
      #       :body=>nil,
      #       :headers=>{},
      #       :read_timeout=>10,
      #       :open_timeout=>10, :sent_at=>nil
      #     }
      #   }
      # @return [Hash]
      def to_h
        {
          code: code,
          body: body,
          headers: headers,
          cookies: cookies,
          request: request.to_h
        }
      end

      # Two response should be equal, if their attributes (request, code, body, headers, cookies) match.
      def ==(other)
        request == other.request   &&
          code    == other.code    &&
          body    == other.body    &&
          headers == other.headers &&
          cookies == other.cookies
      end
    end
  end
end
