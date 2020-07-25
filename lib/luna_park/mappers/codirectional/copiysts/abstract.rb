# frozen_string_literal: true

require 'luna_park/mappers/codirectional/errors'

module LunaPark
  module Mappers
    class Codirectional < Simple
      module Copyists
        class Abstract
          private

          class Undefined; end

          private_constant :Undefined

          def copy_nested(from:, to:, from_path:, to_path:) # rubocop:disable Metrics/MethodLength
            value = if from_path.is_a?(Array) # when given `%i[key path]` - not just `:key`
                      read_nested(from, path: from_path)
                    else # when given just `:key`
                      read_plain(from, key: from_path)
                    end

            return if value == Undefined # omit undefined keys

            if to_path.is_a?(Array) # when given `%i[key path]` - not just `:key`
              write_nested(to, to_path, value)
            else # when given just `:key`
              to[to_path] = value
            end
          end

          def read_nested(from, path:)
            *path_to_head, head_key = path      # split `[:a, :b, :c, :d]` to `[:a, :b, :c]` and `:d`
            head_hash = from.dig(*path_to_head) # from `{a: {b: {c: {d: 'value'}}}}` get `{d: 'value'}`
            return Undefined unless head_hash&.key?(head_key) # when there are no key at the path `[:a, :b, :c, :d]`

            head_hash[head_key] # get 'value' from from `{d: 'value'}` stored at `{a: {b: {c: {d: 'value'}}}}`
          rescue NoMethodError => e
            raise unless e.message.start_with?("undefined method `key?' for")

            raise Errors::NotHashGiven.substitute(e, path: path_to_head, object: head_hash)
          end

          def read_plain(from, key:)
            from.key?(key) ? from[key] : Undefined
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
