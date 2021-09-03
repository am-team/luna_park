# frozen_string_literal: true

module LunaPark
  module Extensions
    module Exceptions
      # class-level mixin
      module Substitutive
        def self.extended(base)
          base.extend  ClassMethods
          base.include InstanceMethods
        end

        module ClassMethods
          # Substitute original exception with save original backtrace.
          #
          # @example bad case
          #   class MyException < StandardError
          #     extend LunaPark::Extensions::Exceptions::Substitutive
          #   end
          #
          #     call_exceptional_lib!
          #   rescue ExceptionalLib::SomeException => e
          #     raise MyException # => raised MyException with backtrace started from `raise MyException`
          #                       #      and not contained origin exception backtrace
          #                       #      that can be very painfull for debug
          #   end
          #
          # @example resolve
          #   begin
          #     call_exceptional_lib!
          #   rescue ExceptionalLib::SomeException => e
          #     raise MyException.substitute(e) # => raised MyException with backtrace started
          #                                     #      from library `raise ExceptionalLib::SomeException`
          #                                     #      so you can easily find out where exception starts
          #   end
          def substitute(origin)
            new = new(origin.message)
            new.backtrace = origin.backtrace
            new.origin    = origin
            new
          end
        end

        module InstanceMethods
          attr_accessor :origin
          attr_writer :backtrace

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
