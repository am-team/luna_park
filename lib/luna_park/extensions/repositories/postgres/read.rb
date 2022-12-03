# frozen_string_literal: true

module LunaPark
  module Extensions
    module Repositories
      module Postgres
        module Read
          def find!(pk_value, for_update: false)
            ds = dataset.where(primary_key => pk_value)
            read_one!(ds, for_update:, not_found_meta: pk_value)
          end

          def find(pk_value, for_update: false)
            ds = dataset.where(primary_key => pk_value)
            read_one(ds, for_update:)
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

          def read_one!(dataset, not_found_meta:, for_update: false)
            read_one(dataset, for_update:).tap do |entity|
              raise Errors::NotFound, "#{short_class_name} (#{not_found_meta})" if entity.nil?
            end
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
