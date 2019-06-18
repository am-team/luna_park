# frozen_string_literal: true

module LunaPark
  module Extensions
    module Dsl
      # @example
      #   class MyEntity
      #     include LunaPark::Extensions::Dsl::Attributes
      #     include LunaPark::Extensions::Dsl::HasPrimaryKey
      #
      #     primary_key :uid
      #   end
      #
      #   entity = MyEntity.new(uid: 'a123')
      #   entity.uid               # => "a123"
      #   entity.pk                # => "a123"
      #   entity.primary_key       # => "a123"
      #   entity.class.primary_key # => :uid
      #
      #   MyEntity.wrap_primary_key(entity) # => "a123"
      #   MyEntity.wrap_primary_key("a123") # => "a123"
      #
      #   def save(input)
      #     entity = MyEntity.wrap(input)
      #     sequel_dataset.where(MyEntity.primary_key => entity.primary_key)
      #     # ...
      #   end
      #
      #   def find(input)
      #     sequel_dataset.where(MyEntity.primary_key => MyEntity.wrap_primary_key(input))
      #     # ...
      #   end
      module HasPrimaryKey
        def self.included(base)
          base.extend ClassMethods
          base.include InstanceMethods
        end

        module ClassMethods
          attr_reader :primary_key_type

          def primary_key(key = nil)
            @primary_key || define_primary_key(key) || raise(
              Errors::NotConfigured, "primary_key is unknown. It must be configured via `#{self}.primary_key(key)`"
            )
          end

          def wrap_primary_key(input)
            input.is_a?(self) ? input.send(@primary_key) : input
          end

          private

          def define_primary_key(key)
            attr(key)
            @primary_key = key
          end
        end

        module InstanceMethods
          def primary_key
            send(self.class.primary_key)
          end
        end
      end
    end
  end
end
