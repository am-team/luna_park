# frozen_string_literal: true

module LunaPark
  module Extensions
    module Repositories
      module Postgres
        module Update
          def save(input, **scope_opts)
            entity = wrap(input)

            entity.updated_at = Time.now if entity.respond_to?(:updated_at)

            row       = to_row(entity)
            new_row   = scoped(**scope_opts).where(primary_key => row[primary_key]).returning.update(row).first
            new_attrs = from_row(new_row)

            entity.set_attributes(new_attrs)
            entity
          end
        end
      end
    end
  end
end
