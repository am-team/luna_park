# frozen_string_literal: true

module LunaPark
  module Repositories
    # @example
    #   class UserRepo < LunaPark::Repositories::Sequel
    #     mapper UserMapper
    #     entity User
    #
    #     def find(id)
    #       to_entity from_row dataset.where(id: id).first
    #     end
    #
    #     def create(input)
    #       entity = wrap(input)
    #       row    = to_row(entity)
    #       new_row   = dataset.returning.insert(row)
    #       new_attrs = from_row(new_attrs)
    #       entity.set_attributes(new_attrs)
    #       entity
    #     end
    #
    #     def dataset
    #       SEQUEL_DB[:users]
    #     end
    #   end
    class Sequel
      class << self
        def mapper(mapper_klass)
          @mapper_klass = mapper_klass
        end

        def entity(entity_class)
          @entity_class = entity_class
        end

        private

        def to_rows(input_array)
          mapper_klass&.to_rows(input_array)
        end

        def to_row(input)
          mapper_klass&.to_row(input)
        end

        def from_rows(rows_array)
          mapper_klass&.from_rows(rows_array)
        end

        def from_row(row)
          mapper_klass&.from_row(row)
        end

        def wrap_all(input_array)
          Array(input_array).map { |input| wrap(input) }
        end

        def wrap(input)
          return if input.nil?

          entity_class.wrap(input)
        end

        def to_entities(attrs_array)
          Array(attrs_array).map { |attrs| to_entity(attrs) }
        end

        def to_entity(attrs)
          return if attrs.nil?

          entity_class.new(attrs)
        end

        attr_reader :mapper_klass, :entity_class
      end
    end
  end
end
