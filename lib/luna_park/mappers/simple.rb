# frozen_string_literal: true

module LunaPark
  module Mappers
    # TODO: refactoring
    # add description
    class Simple < Base
      class << self
        def from_row(row_hash)
          row_hash.to_h.slice(*keys)
        end

        def to_row(attrs_hash)
          attrs_hash.to_h.slice(*keys)
        end

        private

        def map(*keys)
          self.keys.concat(keys) if keys.any?
        end

        def keys
          @keys ||= []
        end
      end
    end
  end
end
