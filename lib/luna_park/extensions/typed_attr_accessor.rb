# frozen_string_literal: true

module LunaPark
  module Extensions
    module TypedAttrAccessor
      def typed_attr_accessor(*names, callable, is_array: false)
        attr_reader(*names)
        typed_attr_writer(*names, callable, is_array:)
      end

      def typed_attr_writer(*names, callable, is_array: false)
        return attr_writer(*names) if callable.nil?

        names.each do |name|
          setter = :"#{name}="
          ivar   = :"@#{name}"
          if is_array
            define_method(setter) { |input| instance_variable_set(ivar, input&.map { |elem| callable.call(elem) }) }
          else
            define_method(setter) { |input| instance_variable_set(ivar, callable.call(input)) }
          end
        end
      end
    end
  end
end
