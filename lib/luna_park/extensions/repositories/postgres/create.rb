# frozen_string_literal: true

module LunaPark
  module Extensions
    module Repositories
      module Postgres
        module Create
          def create(input)
            entity = wrap(input)
            record     = to_record(entity)
            new_record = dataset.returning.insert(record).first
            new_attrs  = from_record(new_record)
            entity.set_attributes(new_attrs)
            entity
          end
        end
      end
    end
  end
end
