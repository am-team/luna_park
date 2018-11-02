# frozen_string_literal: true

module LunaPark
  module Extensions
    module Attributable
      def set_attributes(hash)
        hash.each { |method_name, value| send(:"#{method_name}=", value) }
      rescue NameError => e
        method_name = e.message[/\Aundefined local variable or method `(.+)=' for/]
        raise "Unknown attribute #{method_name} given. \n" \
              "Maybe you forgot to add `attr_accessor :#{method_name}`?"
      end
    end
  end
end
