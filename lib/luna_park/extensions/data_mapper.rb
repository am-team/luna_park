# frozen_string_literal: true

require 'luna_park/mappers/simple'

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
    #       new_row   = products.where(id: entity.id).returning.update(row)
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
      class << self
        def extended(base)
          base.include self
        end

        def included(base)
          base.extend ClassMethods
          base.include InstanceMethods

          base.__define_constants__

          defaults(base)
        end

        private

        def defaults(base)
          base.entity OpenStruct, :new
          base.mapper LunaPark::Mappers::Simple
        end
      end

      module ClassMethods
        attr_reader :entity_class, :mapper_class, :__entity_coercion__

        # Configure repository

        def entity(entity, coercion = nil)
          @entity_class = entity
          @__entity_coercion__ =
            case coercion
            when nil    then default_entity_coercion
            when Symbol then entity_class.method(coercion)
            else
              raise ArgumentError, "Unexpected coercion #{coercion.inspect}" unless coercion.respond_to?(:call)

              coercion
            end
          @entity_class
        end

        # Configure Mapper
        #
        # @example With anonymous mapper
        #   class Repository < LunaPark::Repository
        #     mapper do
        #       attr :foo, row: :fuu
        #     end
        #   end
        #
        #   Repository.mapper_class.to_row(foo: 'Foo') # => { fuu: 'Foo' }
        #
        # @example With mapper class
        #   class Repository::Mapper < LunaPark::Mapper
        #     attr :foo, row: :fuu
        #   end
        #
        #   class Repository < LunaPark::Repository
        #     mapper Mapper
        #   end
        #
        #   Repository.new.mapper_class.to_row(foo: 'Foo') # => { fuu: 'Foo' }
        #
        # @example Without mapper
        #   class Repository < LunaPark::Repository
        #     def example_to_row(attrs)
        #       to_row attrs
        #     end
        #   end
        #
        #   Repository.new.example_to_row(foo: 'Foo') # => { foo: 'Foo' }
        #
        def mapper(mapper = Undefined, &block)
          raise ArgumentError, 'Expected mapper xOR block' unless (mapper == Undefined) ^ block.nil?

          return @mapper_class = mapper if block.nil?

          @mapper_class = Class.new(base_anonymous_mapper)
          @mapper_class.class_eval(&block)
          @mapper_class
        end

        # @abstract
        #
        # @example
        #   class Transaction::Repository < LunaPark::Repository
        #     entity Transaction
        #
        #     def self.default_entity_coercion
        #       entity_class.method(:call)
        #     end
        #   end
        def default_entity_coercion
          return entity_class.method(:call) if entity_class.respond_to?(:call)
          return entity_class.method(:wrap) if entity_class.respond_to?(:wrap)

          ->(input) { entity_class.new(input.to_h) }
        end

        # @abstract
        #
        # @example
        #   class Transaction::Repository < LunaPark::Repository
        #     # Parent of this mapper will be changed
        #     mapper do
        #       attr :foo
        #     end
        #
        #     def self.base_anonymous_mapper
        #       MyBaseMapper
        #     end
        #   end
        def base_anonymous_mapper
          LunaPark::Mappers::Codirectional
        end

        def primary_key(attr)
          @primary_key_attr = attr
        end

        DEFAULT_PRIMARY_KEY = :id

        def primary_key_attr
          @primary_key_attr || DEFAULT_PRIMARY_KEY
        end

        def __define_constants__(not_found: LunaPark::Extensions::DataMapper::NotFound)
          __define_class__ 'NotFound', not_found
        end

        def __define_class__(name, parent)
          klass = Class.new(parent)
          klass.inherited parent
          const_set name, klass
        end

        def inherited(klass)
          klass.__define_constants__(not_found: NotFound)
          klass.entity entity_class, __entity_coercion__
          klass.mapper mapper_class
          super
        end

        class Undefined; end
        private_constant :Undefined
      end

      module InstanceMethods
        def transaction(&block)
          dataset.transaction(&block)
        end

        private

        # Helpers

        # Repository Helpers

        # Get collection of entities from row
        # @example
        #   def where_type(type)
        #     read_all scoped dataset.where(type: type)
        #   end
        def read_all(rows)
          to_entities from_rows __to_array__(rows)
        end

        # Get one entity from row
        # @example
        #   def find(id)
        #     # limit 2 allows to check if there are more than 1 record
        #     read_one dataset.where(id: id).limit(2)
        #   end
        def read_one(rows)
          to_entity from_row __one_from_array__(rows)
        end

        # Get one entity from row
        # @example
        #   def find!(id)
        #     read_one! dataset.where(id: id).limit(1)
        #   end
        def read_one!(row, not_found_by: nil, not_found_meta: nil)
          warn 'Deprecated option #not_found_meta used' unless not_found_meta.nil?

          found! read_one(row), not_found_by: not_found_by || not_found_meta
        end

        def found!(value, not_found_by: nil)
          return value unless value.nil?

          raise self.class::NotFound, "#{self.class.entity_class.name} (#{not_found_by})"
        end

        # Mapper helpers

        # @example
        #   def create(entities)
        #     rows = to_rows(entities)
        #     database.insert_many(rows)
        #   end
        def to_rows(input_array)
          self.class.mapper_class.to_rows(input_array)
        end

        # @example
        #   def create(entity)
        #     row = to_row(entity)
        #     database.insert(row)
        #   end
        def to_row(input)
          self.class.mapper_class.to_row(input)
        end

        # @example
        #   def where_type(type)
        #     entities_attrs = from_rows(products.where(type: type))
        #     entities_attrs.map { |entity_attrs| Entity.new(entity_attrs) }
        #   end
        def from_rows(rows_array)
          self.class.mapper_class.from_rows(rows_array)
        end

        # @example
        #   def find(id)
        #     entity_attrs = from_row(products.where(id: id))
        #     Entity.new(entity_attrs)
        #   end
        def from_row(input)
          return if input.nil?
          raise ArgumentError, 'Can not be an Array' if input.is_a?(Array)

          self.class.mapper_class.from_row(input.to_h)
        end

        # Entity construction helpers

        # @example
        #   to_entities(attributes_hashes) # => Array of Entity
        #   to_entities(attributes_hash)   # => Array of Entity
        def to_entities(attrs_array)
          __to_array__(attrs_array).map { |attrs| to_entity(attrs) }
        end

        # @example
        #   to_entity(attributes_hash) # => Entity
        def to_entity(attrs)
          return if attrs.nil?

          self.class.entity_class.new(attrs)
        end

        # Entity wrapping helpers

        # @example
        #   to_entities(attributes_hashes) # => Array of Entity
        #   to_entities(entities)          # => Array of Entity
        #   to_entities(entity)            # => Array of Entity
        def wrap_all(input_array)
          __to_array__(input_array).map { |input| wrap(input) }
        end

        # @example
        #   wrap(id: 42) # => <#MyEntity @id=42>
        #   wrap(entity) # => <#MyEntity @id=42>
        def wrap(input)
          return if input.nil?

          self.class.__entity_coercion__.call(input)
        end

        # @example scope after query build
        #   def all(**opts)
        #     read_all scoped(**opts).order(:created_at)
        #   end
        #
        # @example scope before query build
        #   def all(**opts)
        #     read_all scoped(dataset.order(:created_at), **opts)
        #   end
        #
        def scoped(ds = dataset, **opts)
          scope(ds, **opts)
        end

        # @abstract
        #
        # @example
        #   def scope(dataset, deleted: nil, for_update: false, **scope)
        #     ds = super(dataset, **scope)
        #     ds = ds.for_update                  if for_update == true
        #     ds = ds.where(deleted_at: nil)      if deleted == false
        #     ds = ds.where.not(deleted_at: nil)  if deleted == true
        #     ds
        #   end
        #
        #   def all(**scope)
        #     read_all scoped(**scope) # same as `scope(dataset, **scope)`
        #   end
        #
        #   all                 # get all
        #   all(deleted: false) # get not deleted
        #   all(deleted: true)  # get deleted
        def scope(dataset, **_scope)
          dataset
        end

        # Read config

        def primary_key
          self.class.primary_key_attr
        end

        # Factory Methods

        # @abstract
        #
        # Usefull for extensions
        def dataset
          raise NotImplementedError
        end

        # fixes problem: `Array({ a: 1 }) # => [[:a, 1]]`
        def __to_array__(input)
          input.is_a?(Hash) ? [input] : Array(input)
        end

        # checks if there are only one item in the given array
        def __one_from_array__(input)
          case input
          when Hash then input
          else
            array = input.is_a?(Array) ? input : Array(input)
            raise MoreThanOneRecord.new count: array.size if array.size > 1

            array.first
          end
        end
      end

      class NotFound < LunaPark::Errors::NotFound; end

      class MoreThanOneRecord < LunaPark::Errors::System
        message { |d| "Expected only one record, but there are #{d[:count]} records" }
      end
    end
  end
end
