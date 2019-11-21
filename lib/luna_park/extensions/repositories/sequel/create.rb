# frozen_string_literal: true

module LunaPark
  module Extensions
    module Repositories
      module Sequel
        module Create
          def create(input)
            entity = wrap(input)
            row    = to_row(entity)
            new_row = dataset.returning.insert(row).first
            new_attrs = from_row(new_row)
            entity.set_attributes(new_attrs)
            entity
          end
        end
      end
    end
  end
end
