# frozen_string_literal: true

module LunaPark
  module Extensions
    module Repositories
      module Postgres
        module Update
          def save(input)
            entity = wrap(input)
            entity.updated_at = Time.now.utc
            record     = to_record(entity)
            new_record = dataset.returning.where(primary_key => record[primary_key]).update(record).first
            new_attrs  = from_record(new_record)
            entity.set_attributes(new_attrs)
            entity
          end
        end
      end
    end
  end
end
