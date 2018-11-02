# frozen_string_literal: true

module LunaPark
  module Extensions
    module Attributable
      def set_attributes(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Expected to receive Hash, but receives #{hash.class} #{hash.inspect}"
        end

        hash.each { |method_name, value| send(:"#{method_name}=", value) }

      rescue NameError => e
        method = e.message[/\Aundefined local variable or method `(.+)=' for/]
        raise NameError, "Unknown attribute #{method} given. \n" \
                         "Maybe you forgot to add `attr_accessor :#{method}`?"
      end
    end
  end
end
