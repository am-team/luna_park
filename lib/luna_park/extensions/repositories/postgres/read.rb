# frozen_string_literal: true

module LunaPark
  module Extensions
    module Repositories
      module Postgres
        module Read
          def find!(pk_value, for_update: false)
            ds = dataset.where(primary_key => pk_value)
            read_one!(ds, for_update: for_update, not_found_meta: pk_value)
          end

          def find(pk_value, for_update: false)
            ds = dataset.where(primary_key => pk_value)
            read_one(ds, for_update: for_update)
          end

          def lock!(pk_value)
            lock(pk_value) || raise(Errors::NotFound, "#{short_class_name} (#{pk_value})")
          end

          def lock(pk_value)
            dataset.for_update.select(primary_key).where(primary_key => pk_value).first ? true : false
          end

          def count
            dataset.count
          end

          def all
            read_all(dataset.order { created_at.desc })
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

            raise Errors::NotFound, "#{short_class_name} (#{not_found_meta})"
          end

          def read_one(dataset, for_update: false)
            dataset = dataset.for_update if for_update
            record = dataset.first
            to_entity from_record(record)
          end

          def read_all(dataset)
            to_entities from_records(dataset)
          end

          def short_class_name
            @short_class_name ||= self.class.name[/::(\w+)\z/, 1]
          end
        end
      end
    end
  end
end
