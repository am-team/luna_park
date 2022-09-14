# frozen_string_literal: true

require 'luna_park/errors/business'
require 'luna_park/errors/system'

module LunaPark
  module Extensions
    ##
    # This is syntax sugar for define exception class
    # in UseCase layer
    #
    # @example without sugar
    #   class Service
    #     class UserNotExists < LunaPark::Errors::Business
    #       message 'Sorry but user does not exists'
    #     end
    #
    #     def call
    #        raise UserNotExists if something_wrong
    #     end
    #   end
    #
    # @example with sugar
    #   class Service
    #     include LunaPark::Extensions::HasErrors
    #     error :user_not_exists, 'Sorry but user does not exists'
    #
    #     def call
    #       error :user_not_exists if something_wrong
    #     end
    #   end
    module HasErrors
      def self.included(base)
        base.extend  ClassMethods
        base.include InstanceMethods
      end

      module InstanceMethods
        ##
        # Raise error defined in class
        #
        # @example
        #   class Service
        #     include LunaPark::Extensions::HasErrors
        #
        #     class CustomError < LunaPark::Errors::Business; end
        #   end
        #
        #   Service.new.error :custom_error # => raise CustomError
        #
        # @param title [Symbol|String] - Title of error
        # @param msg [String] - Message of error
        # @param **attrs - See @LunaPark::Errors::Base#new
        def error(title, msg = nil, **attrs)
          class_name = self.class.error_class_name(title)
          raise self.class.const_get(class_name).new msg, **attrs
        end
      end

      module ClassMethods
        ##
        # Define business error
        #
        # @example
        #   class Service
        #     include LunaPark::Extensions::HasErrors
        #
        #     business_error :logic_error, { (1 + 1).to_s }
        #   end
        #
        #   logic_error = Service::LogicError.new
        #   logic_error.is_a? LunaPark::Errors::Business # => true
        #   logic_error.message # => '2'
        def business_error(title, txt = nil, i18n_key: nil, notify: nil, &default_message_block)
          error_class = Class.new(Errors::Business)
          error_class.message(txt, i18n_key: i18n_key, &default_message_block)
          error_class.notify(notify)
          const_set(error_class_name(title), error_class)
        end

        ##
        # Alias for business error
        alias error business_error

        ##
        # Define business error
        #
        # @example
        #   class Service
        #     include LunaPark::Extensions::HasErrors
        #
        #     system_error :tech_error, 'Custom message'
        #   end
        #
        #   tech_error = Service::TechError.new
        #   tech_error.is_a? LunaPark::Errors::System # => true
        #   tech_error.message # => 'Custom message'
        def system_error(title, txt = nil, i18n_key: nil, notify: nil, &default_message_block)
          error_class = Class.new(Errors::System)
          error_class.message(txt, i18n_key: i18n_key, &default_message_block)
          error_class.notify(notify)
          const_set(error_class_name(title), error_class)
        end

        ##
        # Define error with custom superclass.
        # The superclass must be inherited from LunaPark::Errors::Base.
        #
        # @example
        #
        #   class Service
        #     include LunaPark::Extensions::HasErrors
        #
        #     custom_error :some_error, BaseError, 'Some message'
        #   end
        #
        #   class BaseError < LunaPark::Errors::Business
        #     alias message description
        #   end
        #
        #   custom_error = Service::SomeError
        #   custom_error.is_a? LunaPark::Errors::Business # => true
        #   custom_error.description # => 'Some message'
        # rubocop:disable Metrics/ParameterLists
        def custom_error(title, inherit_from, txt = nil, i18n_key: nil, notify: nil, &default_message_block)
          unless inherit_from < Errors::Base
            raise ArgumentError, 'inherit_from must be a superclass of LunaPark::Errors::Base'
          end

          error_class = Class.new(inherit_from)
          error_class.inherited(inherit_from)
          error_class.notify(notify) unless notify.nil?

          message_present = ![txt, i18n_key, default_message_block].all?(&:nil?)
          error_class.message(txt, i18n_key: i18n_key, &default_message_block) if message_present

          const_set(error_class_name(title), error_class)
        end
        # rubocop:enable Metrics/ParameterLists

        ##
        # Get error class name
        #
        # @example when title is string
        #   error_class_name('CamelCase') # => 'CamelCase'
        #
        # @example when title is symbol
        #   error_class_name(:snake_case) # => 'SnakeCase'
        #
        # @param [String|Symbol] title - short alias for error
        def error_class_name(title)
          case title
          when String then title
          when Symbol then title.to_s.split('_').collect!(&:capitalize).join
          else raise ArgumentError, "Unknown type `#{title}` for error title"
          end
        end
      end
    end
  end
end
