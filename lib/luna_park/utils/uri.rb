# frozen_string_literal: true

require 'forwardable'
require 'luna_park/extensions/attributable'
require 'luna_park/utils/uri/query'

module LunaPark
  module Utils
    # @example
    #   uri = LunaPark::Utils::URI.new('http://example.com/api/v1/users', query: { vip: true }, port: 5000)
    #   uri.to_s # => "http://example.com:5000/api/v1/users?vip=true"
    class URI
      extend Forwardable
      include LunaPark::Extensions::Attributable

      # rubocop:disable Layout/AlignParameters
      def_delegators :uri, :scheme, :host,  :port,  :path, :query, :fragment,
                          :scheme=, :host=, :port=, :path=,        :fragment=
      def_delegators :uri, :userinfo, :user,  :password,
                          :userinfo=, :user=, :password=
      # rubocop:enable Layout/AlignParameters

      def self.wrap(input)
        case input
        when self           then input
        when String         then new(input)
        when ::URI::Generic then new(input)
        when Hash           then new(**input)
        else raise Errors::Unwrapable, "#{self} can not wrap #{input.class}"
        end
      end

      def initialize(path = nil, **attrs)
        @uri = URI(path || '')
        set_attributes(attrs)
      end

      def new(**attrs)
        self.class.new(to_h.merge!(attrs))
      end

      def query=(input)
        uri.query = input && Query.wrap(input)
      end

      COMPONENTS = %i[scheme user password host port path query fragment].freeze

      def ==(other)
        case other
        when self.class then to_h == other.to_h
        when Hash       then to_h == other
        else                 to_s == other.to_s
        end
      end

      def to_h
        output = {}
        COMPONENTS.each do |component|
          value = uri.public_send(component)
          output[component] = value if value
        end
        output
      end

      def to_s
        uri.to_s
      end

      def to_str
        uri.to_s
      end

      def to_uri
        uri
      end

      def inspect
        "#<#{self.class} #{uri}>"
      end

      private

      attr_reader :uri
    end
  end
end
