# frozen_string_literal: true

module LunaPark
  module Extensions
    module Repositories
      module Postgres
        module Read
          def find!(input, for_update: false)
            found! find(input, for_update: for_update), not_found_meta: input
          end

          def find(input, for_update: false)
            ds = dataset.where(wrap_pk_to_record(input))
            read_one(ds, for_update: for_update)
          end

          def count
            dataset.count
          end

          def all
            read_all(dataset.order { created_at.desc })
          end

          def first
            to_entity from_row dataset.order(:created_at).first
          end

          def last
            to_entity from_row dataset.order(:created_at).last
          end

          private

          def read_one!(dataset, for_update: false, not_found_meta:)
            found! read_one(dataset, for_update: for_update), not_found_meta: not_found_meta
          end

          def found!(entity, not_found_meta:)
            return entity if entity

            raise Errors::NotFound, "#{short_class_name} (#{not_found_meta})" if entity.nil?
          end

          def read_one(dataset, for_update: false)
            dataset = dataset.for_update if for_update
            row = dataset.first
            to_entity from_row(row)
          end

          def read_all(dataset)
            to_entities from_rows(dataset)
          end

          def short_class_name
            @short_class_name ||= self.class.name[/::(\w+)\z/, 1]
          end
        end
      end
    end
  end
end
