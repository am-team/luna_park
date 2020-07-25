# frozen_string_literal: true

require 'luna_park/mappers/codirectional/copiysts/abstract'

module LunaPark
  module Mappers
    class Codirectional < Simple
      module Copyists
        # Copyist for copiyng value between two schemas with DIFFERENT NESTING PATHS
        #   (Works with only one described attribute)
        class Asymmetric < Abstract
          def initialize(store_path:, attr_path:)
            @store_path = store_path
            @attr_path = attr_path

            raise 'store path can not be nil' if store_path.nil?
            raise 'attr path can not be nil' if attr_path.nil?
          end

          def from_row(row:, attrs:)
            copy_nested(from: row, to: attrs, from_path: @store_path, to_path: @attr_path)
          end

          def to_row(row:, attrs:)
            copy_nested(from: attrs, to: row, from_path: @attr_path, to_path: @store_path)
          end
        end
      end
    end
  end
end
