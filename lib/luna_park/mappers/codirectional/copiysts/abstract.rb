# frozen_string_literal: true

module LunaPark
  module Mappers
    class Codirectional < Simple
      module Copyists
        class Abstract
          private

          class Undefined; end

          private_constant :Undefined

          def copy_nested(from:, to:, from_path:, to_path:)
            value = read_nested(from, from_path)
            return if value.equal? Undefined # omit undefined keys

            if to_path.is_a?(Array) # when given `%i[key path]` - not just `:key`
              write_nested(to, to_path, value)
            else # when given just `:key`
              to[to_path] = value
            end
          end

          def read_nested(from_hash, path)
            if path.is_a?(Array) # when given `%i[key path]` - not just `:key`
              *tail_path, head_key = path           # split `[:a, :b, :c, :d]` to `[:a, :b, :c]` and `:d`
              head_hash = from_hash.dig(*tail_path) # from `{a: {b: {c: {d: 'value'}}}}` get `{d: 'value'}`
              return Undefined unless head_hash&.key?(head_key) # when there are no key at the path `[:a, :b, :c, :d]`

              head_hash.fetch(head_key) # from `{a: {b: {c: {d: 'value'}}}}` get 'value'
            else # when given just `:key` as path
              return Undefined unless from_hash.key?(path) # when there are no key at the path `:a`

              from_hash.fetch(path) # from `{a: 'value'}` get 'value'
            end
          end

          def write_nested(hash, full_path, value)
            *tail_path, head_key = full_path
            build_nested_hash(hash, tail_path)[head_key] = value
          end

          #
          # @example
          #   nested_hash = { a: {} }
          #   build_nested_hash(nested_hash, [:a, :b, :c]) # => {} # (returns new hash at path [:a, :b, :c])
          #
          #   nested_hash # => { a: { b: { c: {} } } }
          #
          # @example
          #   nested_hash = { a: {} }
          #   build_nested_hash(nested_hash, [:a, :b, :c])[:d] = 'value'
          #
          #   nested_hash # => { a: { b: { c: { d: 'value' } } } }
          def build_nested_hash(nested_hash, path)
            path.inject(nested_hash) { |output, key| output[key] ||= {} }
          end
        end
      end
    end
  end
end
