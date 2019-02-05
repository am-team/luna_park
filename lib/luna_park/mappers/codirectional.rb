# frozen_string_literal: true

module LunaPark
  module Mappers
    # TODO: refactoring
    # add description
    class Codirectional < Simple
      class << self
        def from_row(row_hash)
          attrs_hash = {}
          @instructions.each do |store: nil, attribute: nil, common_keys: nil|
            copy__(
              from: row_hash, to: attrs_hash,
              key_from: store, key_to: attribute, common_keys: common_keys
            )
          end
          attrs_hash
        end

        def to_row(input)
          attrs_hash = input.to_h
          row_hash   = {}
          @instructions.each do |store: nil, attribute: nil, common_keys: nil|
            copy__(
              from: attrs_hash, to: row_hash,
              key_from: attribute, key_to: store, common_keys: common_keys
            )
          end
          row_hash
        end

        private

        def map(*common_keys, store: nil, entity: nil)
          @instructions ||= []
          @instructions << { common_keys: common_keys }        if common_keys.any?
          @instructions << { store: store, attribute: entity } if store && entity
        end

        def copy__(from:, to:, key_from:, key_to:, common_keys:)
          if common_keys
            to.merge!(from.slice(*common_keys))
          else
            complex_copy__(hash_from: from, key_from: key_from, hash_to: to, key_to: key_to)
          end
        end

        def complex_copy__(hash_from:, key_from:, hash_to:, key_to:) # rubocop:disable Metrics/MethodLength:
          value_from =
            if key_from.is_a?(Array)
              *path, head = key_from
              hash = hash_from.dig(*path)
              return unless hash&.key?(head)

              hash[head]
            else
              return unless hash_from.key?(key_from)

              hash_from[key_from]
            end

          if key_to.is_a?(Array)
            write_to_path__(hash_to, key_to, value_from)
          else
            hash_to[key_to] = value_from
          end
        end

        def write_to_path__(output, key_to, value_from)
          *path, head = key_to
          path.inject(output) { |hash, key| hash[key] ||= {} }
          output.dig(*path)[head] = value_from
        end
      end
    end
  end
end
