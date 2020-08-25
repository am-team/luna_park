# frozen_string_literal: true

module LunaPark
  module Extensions
    module Exceptions
      # class-level mixin
      #
      # @example
      #
      # class NotFound < StandardError
      #   extend LunaPark::Extensions::Exceptions::HasDetails
      #
      #   details :model, :search_conditions, :something
      #
      #   def default_message
      #     "Not found #{model} by #{search_conditions}"
      #   end
      #
      #   def something
      #     "#{model} Boo!"
      #   end
      # end
      #
      # begin
      #   raise NotFound.new model: 'User', search_conditions: { id: 10, active: true }
      # rescue => e
      #   e.model             # => "User"
      #   e.search_conditions # => { id: 10, active: true }
      #   e.message           # => "Not found User by { id: 10, active: true }"
      #   e.details           # => { model: 'User', search_conditions: { id: 10, active: true }, something: 'User Boo!' }
      # end
      module HasDetails
        def self.extended(base)
          base.extend  ClassMethods
          base.include Extensions::Attributable
          base.include InstanceMethods
        end

        module ClassMethods
          def details(*new_details)
            return @details if new_details.empty?

            @details ||= []
            attr_accessor(*new_details)
            @details |= new_details
          end
        end

        module InstanceMethods
          def initialize(message = nil, **details)
            set_attributes(details)

            super(message || default_message)
          end

          # @abstract
          def default_message
            nil
          end

          def details
            @details ||= self.class.details.each_with_object({}) do |key, output|
              output[key] = send(key)
            end
          end
        end
      end
    end
  end
end
