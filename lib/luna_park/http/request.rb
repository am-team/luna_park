# frozen_string_literal: true

require 'luna_park/http/send'

module LunaPark
  module Http
    class Request
      DEFAULT_OPEN_TIMEOUT = 10
      DEFAULT_READ_TIMEOUT = 10
      DEFAULT_DRIVER       = LunaPark::Http::Send

      private_constant :DEFAULT_DRIVER

      # Business description for this request, help you
      # make the domain model more expressive
      #
      # @example Get users request
      #   request = Request.new(
      #     title: 'Get users list',
      #     method: :get,
      #     url: 'https://example.com/users'
      #   )
      #
      #   request.title # => 'Get users list'
      attr_accessor :title

      # Http method of current request, defines a set of
      # request methods to indicate the desired action to
      # be performed for a given resource
      #
      # @example Get users request
      #   request.method # => :get
      #
      attr_accessor :method

      # Http url to send request
      #
      # @example Get users request
      #   request.url # => 'http://example.com/users'
      attr_accessor :url

      # Body of http request (defaults is `nil`)
      #
      # @example Get users request
      #
      #   request = Request.new(
      #     title: 'Get users list',
      #     method: :get,
      #     url: 'http://example.com/users',
      #     body: JSON.generate({message: 'Hello!'})
      #   )
      #   request.body # => "{\"message\":\"Hello!\"}"'
      attr_accessor :body

      # Http request headers (defaults is `{}`)
      #
      # @example Get users request
      #   json_request.headers # => {}
      attr_accessor :headers

      # Http read timeout, is the timeout for reading
      # the answer. This is useful to make sure you will not
      # get stuck half way in the reading process, or get
      # stuck reading a 5 MB file when you're expecting 5 KB of JSON
      # (default is 10)
      #
      # @example Get users request
      #   json_request.read_timout # => 10
      attr_accessor :read_timeout

      # Http open timeout, is the timeout for opening
      # the connection. This is useful if you are calling
      # servers with slow or shaky response times. (defaults is 10)
      #
      # @example Get users request
      #   json_request.open_timeout # => 10
      attr_accessor :open_timeout

      # Time when request is sent
      #
      # @example before request is sent
      #   request.sent_at # => nil
      #
      # @example after request has been sent
      #   request.sent_at # => 2020-05-04 16:56:20 +0300
      attr_reader :sent_at

      # Create new request
      #
      # @param title business description (see #title)
      # @param method Http method of current request (see #method)
      # @param url (see #url)
      # @param body (see #body)
      # @param headers (see #headers)
      # @param read_timeout (see #read_timeout)
      # @param open_timeout (see #open_timeout)
      # @param driver is HTTP driver which use to send this request
      # rubocop:disable Metrics/ParameterLists
      def initialize(title:, method:, url:, body: nil, headers: nil, open_timeout: nil, read_timeout: nil, driver: nil)
        @title        = title
        @method       = method
        @url          = url # TODO: Utils::URI
        @body         = body
        @headers      = headers      || {}
        @read_timeout = read_timeout || DEFAULT_READ_TIMEOUT
        @open_timeout = open_timeout || DEFAULT_OPEN_TIMEOUT
        @driver       = driver
        @sent_at      = nil
      end
      # rubocop:enable Metrics/ParameterLists

      # Send current request (we cannot call this method `send` because it
      # reserved word in ruby). It always return Response object, even if
      # the server returned an error such as 404 or 502.
      #
      # @example correct answer
      #  request = Http::Request.new(
      #     title: 'Get users list',
      #     method: :get,
      #     url: 'http:://yandex.ru'
      #   )
      #   request.call # => <LunaPark::Http::Response @code=200 @body="Hello World!" @headers={}>
      #
      # @example Server unavailable
      #   request.call # => <LunaPark::Http::Response @code=503 @body="" @headers={}>
      #
      # After sending the request, the object is frozen. You should dup object to resend request.
      #
      # @note This method implements a facade pattern. And you better use it
      #   than call the Http::Send class directly.
      #
      # @return LunaPark::Http::Response
      def call
        @sent_at = Time.now
        driver.call(self).tap { freeze }
      end

      # Send the current request. It returns a Response object only on a successful response.
      # If the response failed, the call! method should raise an Erros::Http exception.
      #
      # After call! request you cannot change request attributes.
      #
      # @example correct answer
      #  request = Http::Request.new(
      #     title: 'Get users list',
      #     method: :get,
      #     url: 'https://example.com/users'
      #   )
      #   request.call # => <LunaPark::Http::Response @code=200 @body="Hello World!" @headers={}>
      #
      # @example Server unavailable
      #   request.call # => <LunaPark::Http::Response @code=503 @body="" @headers={}>
      #
      # After sending the request, the object is frozen. You should dup object to resend request.
      #
      # @note This method implements a facade pattern. And you better use it
      #   than call the Http::Send class directly.
      #
      # @return LunaPark::Http::Response
      def call!
        @sent_at = Time.now
        driver.call!(self).tap { freeze }
      end

      # When object is duplicated, we should reset send timestamp
      def initialize_dup(_other)
        super
        @sent_at = nil
      end

      # This method shows if this request has been already sent.
      #
      # @return Boolean
      def sent?
        !@sent_at.nil?
      end

      # This method return which driver are use, to send current request.
      def driver
        @driver ||= self.class.default_driver
      end

      # @example inspect get users index request
      #   request = LunaPark::Http::Request.new(
      #     title: 'Get users',
      #     method: :get,
      #     url: 'https://example.com/users'
      #   )
      #
      #   request.inspect # => "<LunaPark::Http::Request @title=\"Get users\"
      #                   #  @url=\"http://localhost:8080/get_200\" @method=\"get\"
      #                   #  @headers=\"{}\" @body=\"\" @sent_at=\"\">"
      def inspect
        "<#{self.class.name} "       \
          "@title=\"#{title}\" "     \
          "@url=\"#{url}\" "         \
          "@method=\"#{method}\" "   \
          "@headers=\"#{headers}\" " \
          "@body=\"#{body}\" "       \
          "@sent_at=\"#{sent_at}\">"
      end

      # @example
      #   request.to_h # => {:title=>"Get users",
      #                      :method=>:get,
      #                      :url=>"http://localhost:8080/get_200",
      #                      :body=>nil,
      #                      :headers=>{},
      #                      :read_timeout=>10,
      #                      :open_timeout=>10}
      def to_h
        {
          title: title,
          method: method,
          url: url,
          body: body,
          headers: headers,
          read_timeout: read_timeout,
          open_timeout: open_timeout,
          sent_at: sent_at
        }
      end

      class << self
        # @return Default driver
        def default_driver
          @default_driver ||= DEFAULT_DRIVER
        end

        # Set diver for this class
        #
        # @example set driver
        #   class Users < Client
        #     driver URI::Send
        #   end
        #
        #   Foobar.default_driver # => URI::Send
        #   Foobar.new.driver     # => URI::Send
        def driver(driver)
          @default_driver = driver
        end
      end
    end
  end
end
