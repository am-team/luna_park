# frozen_string_literal: true

module LunaPark
  module Extensions
    module CoercibleAttrAccessor
      def coercible_attr_accessor(*names, coersion, is_array: false)
        attr_reader(*names)
        coercible_attr_writer(*names, coersion, is_array: is_array)
      end

      def coercible_attr_writer(*names, coersion, is_array: false)
        names.each do |name|
          setter = :"#{name}="
          ivar   = :"@#{name}"
          if is_array
            define_method(setter) { |input| instance_variable_set(ivar, input&.map { |elem| coersion.call(elem) }) }
          else
            define_method(setter) { |input| instance_variable_set(ivar, coersion.call(input)) }
          end
        end
      end
    end
  end
end
