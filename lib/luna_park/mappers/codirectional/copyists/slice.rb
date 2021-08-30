# frozen_string_literal: true

module LunaPark
  module Mappers
    class Codirectional < Simple
      module Copyists
        # Copyist for copiyng value between two schemas with SAME and PLAIN paths
        class Slice
          def initialize
            @keys = []
          end

          def add_key(key)
            @keys << key
          end

          def from_row(row:, attrs:)
            attrs.merge! row.slice(*@keys)
          end

          def to_row(row:, attrs:)
            row.merge! attrs.slice(*@keys)
          end
        end
      end
    end
  end
end
