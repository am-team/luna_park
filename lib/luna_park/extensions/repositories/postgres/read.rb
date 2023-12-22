# frozen_string_literal: true

module LunaPark
  module Extensions
    module Repositories
      module Postgres
        module Read
          def lock!(pk_value)
            transaction { yield find! pk_value, for_update: true }
          end

          def lock(pk_value)
            transaction { yield find pk_value, for_update: true }
          end

          def transaction(&block)
            dataset.transaction(&block)
          end

          def find!(pk_value, **scope)
            found! find(pk_value, **scope), not_found_by: pk_value
          end

          def find(pk_value, **scope)
            read_one scoped(**scope).where(primary_key => pk_value)
          end

          def reload!(entity, **scope)
            new_rows = scoped(**scope).where(primary_key => entity.public_send(primary_key))
            found! new_rows, not_found_by: { primary_key => entity.public_send(primary_key)}

            new_attrs = from_row __one_from__ new_rows
            entity.set_attributes(new_attrs)
            entity
          end

          def count(**scope)
            scoped(**scope).count
          end

          def all(**scope)
            read_all(scoped(**scope).order { created_at.desc })
          end

          def first(**scope)
            read_one scoped(**scope).order(:created_at).first
          end

          def last(**scope)
            read_one scoped(**scope).order(:created_at).last
          end

          private

          def scope(dataset, for_update: false, **_)
            dataset = dataset.for_update if for_update
            dataset
          end
        end
      end
    end
  end
end
