# frozen_string_literal: true

module LunaPark
  module Extensions
    module PredicateAttrAccessor
      def predicate_attr_accessor(*names)
        attr_writer(*names)
        attr_reader?(*names)
      end

      alias attr_accessor? predicate_attr_accessor

      def predicate_attr_reader(*names)
        names.each do |name|
          ivar = :"@#{name}"
          define_method(:"#{name}?") { instance_variable_get(ivar) }
        end
      end

      alias attr_reader? predicate_attr_reader
    end
  end
end
