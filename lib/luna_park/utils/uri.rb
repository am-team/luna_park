# frozen_string_literal: true

require 'forwardable'
require 'luna_park/extensions/attributable'
require 'luna_park/utils/uri/path'
require 'luna_park/utils/uri/query'
require 'luna_park/errors'

module LunaPark
  module Utils
    # URI representation, Wrapper for URI from Ruby stdlib
    #   [http://example.com/foo/bar&baz=bat#42] - URI
    #   |http://example.com/foo/bar|            - URL
    #                     [/foo/bar]            - Path
    #
    # @example
    #   uri = Utils::URI.new('http://example.com/api/v1/users', query: { vip: true }, port: 3000)
    #   uri.to_s # => "http://example.com:3000/api/v1/users?vip=true"
    class URI
      extend Forwardable
      include Extensions::Attributable

      # rubocop:disable Layout/ArgumentAlignment, Layout/ExtraSpacing
      def_delegators :uri, :scheme, :host,  :port,  :path, :query, :fragment,
                          :scheme=, :host=, :port=,                :fragment=
      def_delegators :uri, :userinfo, :user,  :password,
                          :userinfo=, :user=, :password=
      # rubocop:enable Layout/ArgumentAlignment, Layout/ExtraSpacing

      def self.wrap(input)
        case input
        when self           then input
        when String         then new(input)
        when ::URI::Generic then new(input)
        when Hash           then new(**input)
        when nil            then nil
        else raise Errors::Unwrapable, "#{self} can not wrap #{input.class}"
        end
      end

      def initialize(path = nil, **attrs)
        @uri = URI(path || '')
        set_attributes(to_h.merge(attrs))
      end

      # Instrument for dublicate with new parameters
      #
      # @example
      #   uri1 = Utils::URI.new('http://example.com/api/v1/users', query: { vip: false })
      #   uri2 = uri1.new(query: { vip: true }, fragment: 10)
      #   uri1 # => #<LunaPark::Utils::URI http://example.com/api/v1/users&vip=false>
      #   uri2 # => #<LunaPark::Utils::URI http://example.com/api/v1/users&vip=true#10>
      def new(**attrs)
        self.class.new(**to_h.merge!(attrs))
      end

      # Syntax sugar Instead of `uri.dub.tap { |u| u.path += additional_path }``
      def +(subpath) # rubocop:disable Naming/BinaryOperatorParameterName
        new = dup
        new.path += Path.wrap(subpath).to_subpath!
        new
      end

      def path=(input)
        uri.path = input && Path.wrap(input).to_root!
      end

      def query=(input)
        uri.query = input && Query.wrap(input)
      end

      COMPONENTS = %i[scheme user password host port path query fragment].freeze

      def ==(other)
        other.is_a?(Hash) ? to_h == other : to_s == other.to_s
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

      def dup
        self.class.new(to_s)
      end

      protected

      attr_accessor :uri
    end
  end
end
