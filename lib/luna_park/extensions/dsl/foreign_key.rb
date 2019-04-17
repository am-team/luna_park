# frozen_string_literal: true

module LunaPark
  module Extensions
    module Dsl
      # @example
      #  class Transaction
      #    # ...
      #    include LunaPark::Extensions::Dsl::ForeignKey
      #
      #    foreign_key :user_uid, :user, primary_key: :uid # `primary_key:` default is `:id`
      #                                                    # foreign_key points to primary_key
      #
      #    # OR alias:
      #    fk :user_uid, :user, pk: :uid
      #
      #    # ...
      #  end
      #
      #  t = Transaction.new
      #  t1.user # => nil
      #  t1.user_uid # => nil
      #
      #  t1.user = User.new(uid: 42)
      #  t1.user # => #<User uid=42>
      #  t1.user_uid # => 42 (changed)
      #
      #  t1.user # => #<User uid=42>
      #  t1.user = nil
      #  t1.user_uid # => nil (removed)
      #
      #  t1.user # => #<User uid=42>
      #  t1.user_uid = nil
      #  t1.user # => nil (removed)
      #
      #  t1.user # => #<User uid=42>
      #  t1.user = User.new(uid: 666)
      #  t1.user_uid # => 666 (changed)
      #
      #  t1.user # => #<User uid=42>
      #  t1.user_uid = 666
      #  t1.user # => nil (removed cause uid missmatch)
      module ForeignKey
        def self.extended(base)
          base.extend  ClassMethods
          base.include InstanceMethods
        end

        module ClassMethods
          def fk(fk_name, assoc_name, pk: :id)
            foreign_key(fk_name, assoc_name, primary_key: pk)
          end

          def foreign_key(fk_name, assoc_name, primary_key: :id) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
            pk_name = primary_key
            serializable_attributes(fk_name) if include?(Serializable)
            comparable_attributes(fk_name)   if include?(Comparable)

            attr_reader fk_name, assoc_name

            define_method(:"#{assoc_name}=") do |new_assoc|
              new_assoc_pk = extract_pk_value_from_object__(new_assoc, pk_name)
              instance_variable_set(:"@#{fk_name}", new_assoc_pk)
              instance_variable_set(:"@#{assoc_name}", new_assoc)
            end

            define_method(:"#{fk_name}=") do |new_fk|
              assoc = public_send(assoc_name)
              instance_variable_set(:"@#{fk_name}", new_fk)
              return new_fk if assoc.nil?

              current_assoc_pk = extract_pk_value_from_object__(assoc, pk_name)
              instance_variable_set(:"@#{assoc_name}", nil) unless new_fk == current_assoc_pk
              new_fk
            end
          end
        end

        module InstanceMethods
          private

          def extract_pk_value_from_object__(object, pk_name)
            object.respond_to?(:[]) && object[pk_name] ||
              object.respond_to?(pk_name) && object.public_send(pk_name) ||
              nil
          end
        end
      end
    end
  end
end
