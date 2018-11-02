# frozen_string_literal: true

module LunaPark
  module Extensions
    module Attributable
      private

      def public_set_attributes(hash)
        __guard_hash(hash)

        __rename_no_method_exception do
          hash.each { |k, v| public_send(:"#{k}=", v) }
        end
      end

      def set_attributes(hash)
        __guard_hash(hash)

        __rename_no_method_exception do
          hash.each { |k, v| send(:"#{k}=", v) }
        end
      end

      def __guard_hash(hash)
        return if hash.is_a?(Hash)

        raise TypeError, "Expected to receive Hash, but receives #{hash.class} #{hash.inspect}"
      end

      def __rename_no_method_exception
        yield
        rescue NameError => e
          method = e.message[/\Aundefined local variable or method `(.+)=' for/]

          raise if method.nil?

          raise NameError, "Unknown attribute #{method} given. \n" \
                           "Maybe you forgot to add `attr_accessor :#{method}`?"
      end
    end
  end
end
