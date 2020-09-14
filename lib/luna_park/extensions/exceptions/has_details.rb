# frozen_string_literal: true

module LunaPark
  module Extensions
    module Exceptions
      # class-level mixin
      #
      # Allows to easily create exceptions with detailed info
      #
      # @example default usage
      #   class MyException < StandardError
      #     extend LunaPark::Extensions::Exceptions::HasDetails
      #
      #     details :name, :title
      #
      #     def default_message
      #       "User `#{name}` is not allowed to edit `#{title}`"
      #     end
      #   end
      #
      #   begin
      #     raise MyException.new(name: 'John Doe', title: 'The Book')
      #   rescue => e
      #     puts e.name    # => "John Doe"
      #     puts e.title   # => "The Book"
      #     puts e.details # => { name: 'John Doe', title: 'The Book' }
      #     puts e.message # => "User `John Doe` is not allowed to edit `The Book`"
      #   end
      module HasDetails
        def self.extended(base)
          base.extend  ClassMethods
          base.include InstanceMethods
        end

        module ClassMethods
          def details(*details)
            return @details if details.empty?

            attr_accessor(*details)

            @details ||= Set.new
            @details += details
          end
        end

        module InstanceMethods
          def initialize(msg = nil, **details)
            details.each_pair { |detail, value| send(:"#{detail}=", value) }

            super(msg || default_message)
          end

          # @abstract
          def default_message
            nil
          end

          def details
            self.class.details.each_with_object({}) { |detail, output| output[detail] = send(detail) }
          end
        end
      end
    end
  end
end
