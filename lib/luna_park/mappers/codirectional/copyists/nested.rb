# frozen_string_literal: true

module LunaPark
  module Mappers
    class Codirectional < Simple
      module Copyists
        # Copyist for copiyng value between two schemas with DIFFERENT or NESTED paths
        #   (Works with only one described attribute)
        class Nested
          def initialize(attrs_path:, row_path:, mapper:, map_array:)
            @attrs_path = attrs_path
            @row_path   = row_path

            @mapper_config = mapper
            @map_array     = map_array

            raise ArgumentError, 'attr path can not be nil'  if attrs_path.nil?
            raise ArgumentError, 'store path can not be nil' if row_path.nil?
            raise ArgumentError, 'array predicate MUST be nil when no Mapper given' if map_array && mapper.nil?
          end

          def from_row(row:, attrs:)
            copy_nested(from: row, to: attrs, from_path: @row_path, to_path: @attrs_path, direction: :from_row)
          end

          def to_row(row:, attrs:)
            copy_nested(from: attrs, to: row, from_path: @attrs_path, to_path: @row_path, direction: :to_row)
          end

          private

          def copy_nested(from:, to:, from_path:, to_path:, direction:)
            value = read(from, from_path)

            return if value == Undefined # omit undefined keys

            value = apply_mapper(value, direction) unless mapper.nil?

            write(to, to_path, value)
          end

          def apply_mapper(value, direction)
            case @map_array
            when true  then value.map { |v| mapper.public_send direction, v }
            when false then mapper.public_send direction, value
            else
              @map_array = value.respond_to?(:to_a)
              apply_mapper(@map_array ? value.to_a : value, direction)
            end
          end

          def read(from, from_path)
            if from_path.is_a?(Array) # when given `%i[key path]` - not just `:key`
              read_nested(from, path: from_path)
            else # when given just `:key`
              read_plain(from, key: from_path)
            end
          end

          def write(to, to_path, value)
            if to_path.is_a?(Array) # when given `%i[key path]` - not just `:key`
              write_nested(to, to_path, value)
            else # when given just `:key`
              to[to_path] = value
            end
          end

          def read_nested(from, path:)
            *path_to_head, head_key = path      # split `[:a, :b, :c]` to `[:a, :b]` and `:c`
            head_hash = from.dig(*path_to_head) # from `{a: {b: {c: 'value'}}}` get `{c: 'value'}`

            return Undefined if     head_hash.nil?           # when there are no key at the path `[:a, :b]`
            return Undefined unless head_hash.key?(head_key) # when there are no key at the path `[:a, :b, :c]`

            head_hash[head_key] # get 'value' from from `{c: 'value'}` stored at `{a: {b: {c: 'value'}}}`
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
          #   hash = { a: { x: 'x' } }
          #   build_nested_hash(hash, [:a, :b, :c]) # => {} # (returns new hash at path [:a, :b, :c])
          #   hash # => { a: { b: { c: {} }, x: 'x' } }
          #
          # @example
          #   hash = { a: { x: 'x' } }
          #   build_nested_hash(hash, [:a, :b, :c])[:d] = 'value'
          #   hash # => { a: { b: { c: { d: 'value' } }, x: 'x' } }
          def build_nested_hash(nested_hash, path)
            path.inject(nested_hash) { |output, key| output[key] ||= {} }
          end

          def mapper
            return @mapper if instance_variable_defined?(:@mapper)
            return @mapper = Object.const_get(@mapper_config) if @mapper_config.is_a? String

            @mapper = @mapper_config
          end

          class Undefined; end

          private_constant :Undefined
        end
      end
    end
  end
end
