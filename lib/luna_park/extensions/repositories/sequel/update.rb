# frozen_string_literal: true

module LunaPark
  module Extensions
    module Repositories
      module Sequel
        module Update
          def save(input)
            entity = wrap(input)
            entity.updated_at = Time.now.utc
            row = to_row(entity)
            new_row   = dataset.returning.where(uid: entity.uid).update(row).first
            new_attrs = from_row(new_row)
            entity.set_attributes(new_attrs)
            entity
          end
        end
      end
    end
  end
end
