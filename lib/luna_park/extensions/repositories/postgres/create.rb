# frozen_string_literal: true

module LunaPark
  module Extensions
    module Repositories
      module Postgres
        module Create
          def create(input)
            entity = wrap(input)

            time = Time.now
            entity.created_at = time if entity.respond_to?(:created_at)
            entity.updated_at = time if entity.respond_to?(:updated_at)

            row       = to_row(entity)
            new_row   = dataset.returning.insert(row).first
            new_attrs = from_row(new_row)

            entity.set_attributes(new_attrs)
            entity
          end
        end
      end
    end
  end
end
