# frozen_string_literal: true

module LunaPark
  module Extensions
    module Repositories
      module Sequel
        module Read
          def find!(uid, for_update: false)
            ds = dataset.where(uid: uid)
            read_one!(ds, for_update: for_update, not_found_meta: uid)
          end

          def find(uid, for_update: false)
            ds = dataset.where(uid: uid)
            read_one(ds, for_update: for_update)
          end

          def lock(uid)
            dataset.for_update.select(:uid).where(uid: uid).first ? true : false
          end

          def lock!(uid)
            return true if dataset.for_update.select(:uid).where(uid: uid).first

            raise Errors::NotFound, "#{short_class_name} (#{uid})"
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
            read_one(dataset, for_update: for_update).tap do |entity|
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
