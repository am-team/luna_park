# frozen_string_literal: true

require 'forwardable'
require 'luna_park/extensions/attributable'
require 'luna_park/utils/uri/path'
require 'luna_park/utils/uri/query'
require 'luna_park/errors'

module LunaPark
  module Utils
    # URI representatnion ()
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

      def new(**attrs)
        self.class.new(**to_h.merge!(attrs))
      end

      # Syntax sugar Instead of `uri.dub.tap { |u| u.path += additional_path }``
      def +(additional_path) # rubocop:disable Naming/BinaryOperatorParameterName
        new = dup
        new.path += Path.wrap(additional_path)
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
