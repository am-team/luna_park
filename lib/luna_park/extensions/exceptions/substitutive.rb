# frozen_string_literal: true

module LunaPark
  module Extensions
    module Exceptions
      # class-level mixin
      # @example
      #   class MyException < StandardError
      #     extend LunaPark::Extensions::Exceptions::Substitutive
      #   end
      #
      #   ############
      #   # BAD CASE #
      #   ############
      #   begin
      #     call_exceptional_lib!
      #   rescue ExceptionalLib::SomeException => e
      #     raise MyException # => raised MyException with backtrace started from `raise MyException`
      #                       #      and not contained origin exception backtrace
      #                       #      that can be very painfull for debug
      #   end
      #
      #   ###########
      #   # RESOLVE #
      #   ###########
      #   begin
      #     call_exceptional_lib!
      #   rescue ExceptionalLib::SomeException => e
      #     raise MyException.substitute(e) # => raised MyException with backtrace started
      #                                     #      from library `raise ExceptionalLib::SomeException`
      #                                     #      so you can easily find out where exception starts
      #   end
      module Substitutive
        def self.extended(base)
          base.extend  ClassMethods
          base.include InstanceMethods
        end

        module ClassMethods
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
        end
      end
    end
  end
end
