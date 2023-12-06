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
        #     attr_reader :foo
        #
        #     class LogicError < LunaPark::Errors::Business; end
        #   end
        #
        #   Service.new.error :logic_error, expose: :foo # => raise LogicError details: { foo: nil }
        #
        # @param title [Symbol|String] - Title of error
        # @param msg [String] - Message of error
        # @param **details - See @LunaPark::Errors::Base#new
        def error(title, msg = nil, expose: nil, **extra_details)
          class_name = self.class.error_class_name(title)

          if expose
            error_details = {}
            Array(expose).each { |m| error_details[m] = send(m) if respond_to?(m, true) }
          else
            error_details = details.dup
          end

          error_details.merge!(extra_details)

          raise self.class.const_get(class_name).new msg, **error_details
        end

        def details
          return @details if @details

          details = {}
          self.class.__expose_to_details__&.each { |m| details[m] = send(m) if respond_to?(m, true) }
          @details = details
        end
      end

      module ClassMethods
        attr_reader :__expose_to_details__

        def inherited(child)
          child.default_error default_error
          child.expose_to_details(*__expose_to_details__)
        end

        ##
        # Define default error (by default - Business error)
        #
        # @example default error (business error)
        #   class Service
        #     include LunaPark::Extensions::HasErrors
        #
        #     error :logic_error
        #   end
        #
        #   Service::LogicError.new.is_a? LunaPark::Errors::Business # => true
        #
        # @example custom error
        #   class Service
        #     include LunaPark::Extensions::HasErrors
        #
        #     default_error MyCustomError
        #
        #     error :logic_error
        #   end
        #
        #   Service::LogicError.new.is_a? MyCustomError # => true
        def error(title, txt = nil, i18n_key: nil, i18n: nil, notify: nil, &default_message_block) # rubocop:disable Metrics/ParameterLists
          custom_error title, default_error, txt, i18n: i18n || i18n_key, notify: notify, &default_message_block
        end

        # @example define custom default error for `.error`
        #   class Service
        #     include LunaPark::Extensions::HasErrors
        #
        #     default_error MyCustomError
        #
        #     error :logic_error
        #   end
        #
        #   Service::LogicError.new.is_a? MyCustomError # => true
        def default_error(error = nil)
          error.nil? ? (@default_error ||= Errors::Business) : (@default_error = error)
        end

        ##
        # Define business error
        #
        # @example
        #   class Service
        #     include LunaPark::Extensions::HasErrors
        #
        #     business_error(:logic_error) { 1 + 1 }
        #   end
        #
        #   logic_error = Service::LogicError.new
        #   logic_error.is_a? LunaPark::Errors::Business # => true
        #   logic_error.message # => '2'
        def business_error(title, txt = nil, i18n_key: nil, i18n: nil, notify: nil, &default_message_block) # rubocop:disable Metrics/ParameterLists
          custom_error title, Errors::Business, txt, i18n: i18n || i18n_key, notify: notify, &default_message_block
        end

        ##
        # Define business error
        #
        # @example
        #   class Service
        #     include LunaPark::Extensions::HasErrors
        #
        #     system_error :tech_error, 'Error message'
        #   end
        #
        #   tech_error = Service::TechError.new
        #   tech_error.is_a? LunaPark::Errors::System # => true
        #   tech_error.message # => 'Error message'
        def system_error(title, txt = nil, i18n_key: nil, i18n: nil, notify: nil, &default_message_block) # rubocop:disable Metrics/ParameterLists
          custom_error title, Errors::System, txt, i18n: i18n || i18n_key, notify: notify, &default_message_block
        end

        ##
        # Define error with a custom superclass.
        # The superclass must be inherited from LunaPark::Errors::Base
        #
        # @example
        #   class BaseError < LunaPark::Errors::Business
        #     alias description message
        #   end
        #
        #   class Service
        #     include LunaPark::Extensions::HasErrors
        #
        #     custom_error :custom_error, BaseError, 'Error message'
        #   end
        #
        #   custom_error = Service::CustomError.new
        #   custom_error.is_a? BaseError # => true
        #   custom_error.description # => 'Error message'
        # rubocop:disable Metrics/ParameterLists
        def custom_error(title, inherit_from, txt = nil, i18n_key: nil, i18n: nil, notify: nil, &default_message_block)
          unless inherit_from < Errors::Base
            raise ArgumentError, "inherit_from must be a superclass of #{LunaPark::Errors::Base}"
          end

          error_class = Class.new(inherit_from)
          error_class.inherited(inherit_from)
          error_class.notify(notify) unless notify.nil?

          message_present = [txt, i18n || i18n_key, default_message_block].any?
          error_class.message(txt, i18n: i18n || i18n_key, &default_message_block) if message_present

          const_set(error_class_name(title), error_class)
        end
        # rubocop:enable Metrics/ParameterLists

        ##
        # Describe methods to fill Errors details
        #
        # @example
        #   class Service
        #     error :cooldown
        #
        #     expose_to_details :username, :next_attempt_at
        #
        #     # ...
        #   end
        #
        #   begin
        #     Service.new(username: 'Username', next_attempt_at: '40_000').error :cooldown
        #   rescue => e
        #     error = e
        #   end
        #
        #   error.details # => { username: 'Username', next_attempt_at: '40_000' }
        def expose_to_details(*methods)
          @__expose_to_details__ ||= []
          @__expose_to_details__.concat methods
        end

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
          else raise ArgumentError, "Unexpected type `#{title}` for error title"
          end
        end
      end
    end
  end
end
