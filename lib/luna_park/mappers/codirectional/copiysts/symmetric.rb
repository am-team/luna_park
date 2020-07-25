# frozen_string_literal: true

require 'luna_park/mappers/codirectional/copiysts/abstract'

module LunaPark
  module Mappers
    class Codirectional < Simple
      module Copyists
        # Copyist for copiyng value between two schemas with SAME NESTING PATHS
        #   (Works with Array of described attributes)
        class Symmetric < Abstract
          # @keypaths is paths like [[:charge, :amount], [:charge, :currency]]
          # @keys     is keys  like [:id, :comment]
          def initialize(keys)
            @keypaths, @keys = keys.partition { |key| key.is_a?(Array) }
          end

          def from_row(row:, attrs:)
            attrs.merge! row.slice(*@keys)
            @keypaths.each { |path| copy_nested(from: row, to: attrs, from_path: path, to_path: path) }
          end

          def to_row(row:, attrs:)
            row.merge! attrs.slice(*@keys)
            @keypaths.each { |path| copy_nested(from: attrs, to: row, from_path: path, to_path: path) }
          end
        end
      end
    end
  end
end
