# frozen_string_literal: true

require 'uri'

module LunaPark
  module Utils
    class URI
      # `Query` part of `URI`
      #   [http://example.com/foo/bar?baz=bat&quux=quux#42] - URI
      #                              [baz=bat&quux=quux]    - Query
      # @example
      #   query = LunaPark::Utils::URI::Query.wrap('foo=bar&baz=42')
      #   query['foo'] # => 'bar'
      #   query.to_h   # => { 'foo' => 'bar', 'baz' => '42' }
      #   query.to_a   # => [['foo', 'bar'], ['baz', '42']]
      #
      #   query = LunaPark::Utils::URI::Query.wrap(foo: 'bar', baz: 42)
      #   query['bar'] # => '42'
      #   query        # => "foo=bar&baz=42"
      class Query < String
        class << self
          def wrap(input)
            case input
            when String then new(input)
            when Hash   then build(input)
            when Array  then build(input)
            else raise Errors::Unwrapable, "#{self} can not wrap #{input.class}"
            end
          end

          def build(input)
            new(encode(input) || '')
          end

          private

          def encode(hashmap_or_array)
            ::URI.encode_www_form(hashmap_or_array) if hashmap_or_array
          end
        end

        def ==(other)
          case other
          when self.class then super
          when String     then super
          when Hash       then to_h == other
          when Array      then to_a == other
          else                 super(other.to_s)
          end
        end

        def [](key)
          to_h[key]
        end

        def to_h
          @to_h ||= to_a.to_h
        end

        def to_a
          @to_a ||= decode
        end

        private

        def decode
          ::URI.decode_www_form(self)
        end
      end
    end
  end
end
