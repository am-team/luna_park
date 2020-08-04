# frozen_string_literal: true

module LunaPark
  module Extensions
    module Exceptions
      # class-level mixin
      #
      # @example Bad case (without Substitutive)
      #   class CustomException < StandardError; end
      #
      #   begin
      #     use_exceptional_gem!
      #   rescue ExceptionFromGem => ex
      #     raise CustomException
      #   end
      #
      #   # Raised exception has backtrace started from `raise CustomException`
      #   # So it's not containing the origin backtrace, that can be very painfull for debug
      #
      # @example Good case (with Substitutive)
      #   class CustomException < StandardError
      #     extend LunaPark::Extensions::Exceptions::Substitutive
      #   end
      #
      #   begin
      #     use_exceptional_gem!
      #   rescue ExceptionFromGem => ex
      #     raise CustomException.substitute(ex, "Oh! That's bad!", custom_data: ex.detail)
      #   end
      #
      #   # Raised exception has backtrace started from origin backtrace of ExceptionFromGem
      #   # So you can easily find out where was the exception started
      module Substitutive
        def self.extended(base)
          base.extend  ClassMethods
          base.include InstanceMethods
        end

        module ClassMethods
          def substitute(origin, *args, **opts)
            instance = __initializer_has_named_args? ? new(*args, **opts) : new(*args)
            instance.substitute!(origin)
          end

          private

          def __initializer_has_named_args?
            return @__initializer_has_named_args unless @__initializer_has_named_args.nil?

            signature      = instance_method(:initialize).parameters
            arg_types      = signature.map!(&:first)
            has_named_args = arg_types.any? { |arg_type| %i[keyreq key keyrest].include?(arg_type) }

            @__initializer_has_named_args = has_named_args
          end
        end

        module InstanceMethods
          attr_reader :origin

          def substitute!(origin)
            @origin = origin
            self
          end

          def backtrace
            super || origin&.backtrace
          end
        end
      end
    end
  end
end
