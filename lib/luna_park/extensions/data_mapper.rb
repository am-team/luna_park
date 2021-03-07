# frozen_string_literal: true

module LunaPark
  module Extensions
    # @example
    #   class ProductRepository
    #     include LunaPark::Extensions::DataMapper
    #
    #     entity Product
    #     mapper ProductMapper
    #
    #     def find(id)
    #       read_one products.where(id: id)
    #     end
    #
    #     def all
    #       read_all products
    #     end
    #
    #     def save(input)
    #       entity     = wrap(input)
    #       record     = to_record(entity)
    #       new_record = products.where(id: entity.id).update(record)
    #       new_attrs  = from_record(new_record)
    #       entity.set_attributes(new_attrs)
    #       entity
    #     end
    #
    #     private
    #
    #     # Common dataset method is usefull for extensions
    #     def dataset
    #       SEQUEL_CONNECTION[:products]
    #     end
    #
    #     alias products dataset
    #   end
    module DataMapper
      def self.included(base)
        base.extend ClassMethods
        base.include InstanceMethods
      end

      module ClassMethods
        attr_reader :entity_class, :mapper_class

        # Configure repository

        def entity(entity_class = nil)
          @entity_class = entity_class
        end

        def mapper(mapper_class = nil)
          @mapper_class = mapper_class
        end

        DEFAULT_PRIMARY_KEY = :id

        def primary_key(pk = nil)
          @db_primary_key = pk
        end

        def db_primary_key
          @db_primary_key || DEFAULT_PRIMARY_KEY
        end
      end

      module InstanceMethods
        def transaction(&block)
          dataset.transaction(&block)
        end

        private

        # Helpers

        # Get collection of entities from record
        # @example
        #   def where_type(type)
        #     read_all products.where(type: type)
        #   end
        def read_all(records)
          to_entities from_records records.to_a
        end

        # Get one entity from record
        # @example
        #   def find(id)
        #     read_all products.where(id: id)
        #   end
        def read_one(record)
          to_entity from_record record
        end

        # Mapper helpers

        # @example
        #   def create(entities)
        #     records = to_records(entities)
        #     database.insert_many(records)
        #   end
        def to_records(input_array)
          mapper_class ? mapper_class.to_records(input_array) : input_array.map(&:to_h)
        end

        # @example
        #   def create(entity)
        #     record = to_record(entity)
        #     database.insert(record)
        #   end
        def to_record(input)
          mapper_class ? mapper_class.to_record(input) : input.to_h
        end

        # @example
        #   def where_type(type)
        #     entities_attrs = from_records(products.where(type: type))
        #     entities_attrs.map { |entity_attrs| Entity.new(entity_attrs) }
        #   end
        def from_records(records_array)
          mapper_class ? mapper_class.from_records(records_array) : records_array
        end

        # @example
        #   def find(id)
        #     entity_attrs = from_record(products.where(id: id))
        #     Entity.new(entity_attrs)
        #   end
        def from_record(input)
          return if input.nil?
          raise ArgumentError, 'Can not be an Array' if input.is_a?(Array)

          mapper_class ? mapper_class.from_record(input.to_h) : input
        end

        # @deprecated
        def to_rows(input_array)
          to_records(input_array)
        end

        # @deprecated
        def to_row(input)
          to_record(input)
        end

        # @deprecated
        def from_rows(records_array)
          from_records(records_array)
        end

        # @deprecated
        def from_row(input)
          from_record(input)
        end

        # Entity construction helpers

        # @example
        #   to_entities(attributes_hashes) # => Array of Entity
        #   to_entities(attributes_hash)   # => Array of Entity
        def to_entities(attrs_array)
          Array(attrs_array).map { |attrs| to_entity(attrs) }
        end

        # @example
        #   to_entity(attributes_hash) # => Entity
        def to_entity(attrs)
          return if attrs.nil?

          entity_class ? entity_class.wrap(attrs) : attrs
        end

        # Entity wrapping helpers

        # @example
        #   to_entities(attributes_hashes) # => Array of Entity
        #   to_entities(entities)          # => Array of Entity
        #   to_entities(entity)            # => Array of Entity
        def wrap_all(input_array)
          Array(input_array).map { |input| wrap(input) }
        end

        # @example
        #   to_entity(attributes_hash) # => Entity
        #   to_entity(entity)          # => Entity
        def wrap(input)
          return if input.nil?

          entity_class ? entity_class.wrap(input) : input
        end

        # Read config

        def mapper_class
          self.class.mapper_class
        end

        def entity_class
          self.class.entity_class
        end

        def primary_key
          self.class.db_primary_key
        end

        # Factory Methods

        # Usefull for extensions
        def dataset
          raise NotImplementedError
        end
      end
    end
  end
end
