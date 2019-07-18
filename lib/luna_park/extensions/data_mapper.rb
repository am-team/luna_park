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
    #       entity = wrap(input)
    #       row    = to_row(entity)
    #       new_row   = products.where(id: entity.id).update(row)
    #       new_attrs = from_row(new_row)
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
      end

      module InstanceMethods
        def transaction(&block)
          dataset.transaction(&block)
        end

        private

        # Helpers

        # Get collection of entities from row
        # @example
        #   def where_type(type)
        #     read_all products.where(type: type)
        #   end
        def read_all(rows)
          to_entities from_rows rows.to_a
        end

        # Get one entity from row
        # @example
        #   def find(id)
        #     read_all products.where(id: id)
        #   end
        def read_one(row)
          to_entity from_row row
        end

        # Mapper helpers

        # @example
        #   def create(entities)
        #     rows = to_rows(entities)
        #     database.insert_many(rows)
        #   end
        def to_rows(input_array)
          mapper_class.to_rows(input_array)
        end

        # @example
        #   def create(entity)
        #     row = to_row(entity)
        #     database.insert(row)
        #   end
        def to_row(input)
          mapper_class.to_row(input)
        end

        # @example
        #   def where_type(type)
        #     entities_attrs = from_rows(products.where(type: type))
        #     entities_attrs.map { |entity_attrs| Entity.new(entity_attrs) }
        #   end
        def from_rows(rows_array)
          mapper_class.from_rows(rows_array)
        end

        # @example
        #   def find(id)
        #     entity_attrs = from_row(products.where(id: id))
        #     Entity.new(entity_attrs)
        #   end
        def from_row(input)
          return if input.nil?
          raise ArgumentError, 'Can not be an Array' if input.is_a?(Array)

          mapper_class.from_row(input.to_h)
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

          entity_class&.new(attrs) || attrs
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

          entity_class.wrap(input)
        end

        # Read config

        def mapper_class
          self.class.mapper_class
        end

        def entity_class
          self.class.entity_class
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
