# frozen_string_literal: true

module LunaPark
  module Mappers
    class Codirectional < Simple
      module Copyists
        # Copyist for copiyng value between two schemas with SAME and PLAIN paths
        class Plain
          def initialize
            @keys = []
          end

          def add_key(key)
            @keys << key
          end

          def from_record(record:, attrs:)
            attrs.merge! record.slice(*@keys)
          end

          def to_record(record:, attrs:)
            record.merge! attrs.slice(*@keys)
          end
        end
      end
    end
  end
end
