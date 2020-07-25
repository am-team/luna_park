# frozen_string_literal: true

module LunaPark
  module Extensions
    module Exceptions
      # class-level mixin
      # @example
      #   ##############################
      #   # BAD (without Substitutive) #
      #   ##############################
      #
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
      # @example
      #   ############################
      #   # GOOD (with Substitutive) #
      #   ############################
      #
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
          def substitute(origin, message = nil, *args, **opts)
            if __initializer_has_named_args?
              new(message, *args, **opts).substitute!(origin)
            else
              new(message, *args).substitute!(origin)
            end
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
          attr_accessor :origin
          attr_writer :backtrace

          def substitute!(origin)
            self.backtrace = origin.backtrace
            self.origin    = origin
            self
          end

          def backtrace
            super || @backtrace
          end

          # Cover up trace for current exception
          #
          # @example bad case
          #   begin
          #     call_exceptional_lib!
          #   rescue ExceptionalLib::SomeException => e
          #     send_alert_to_developer
          #     raise e # => raised `ExceptionalLib::SomeException` with backtrace started
          #             #      from current line and not contained origin exception backtrace
          #             #      that can be very painful for debug
          #   end
          #
          # @example resolve
          #     begin
          #       call_exceptional_lib!
          #     rescue ExceptionalLib::SomeException => e
          #       send_alert_to_developer
          #       raise e.cover_up_backtrace # => raised `ExceptionalLib::SomeException` with original backtrace
          #                                  #       so you can easily find out where exception starts
          #     end
          def cover_up_backtrace
            new = dup
            new.backtrace = backtrace
            new.origin    = self
            new
          end
        end
      end
    end
  end
end
