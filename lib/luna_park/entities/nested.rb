# frozen_string_literal: true

require_relative 'attributable'

module LunaPark
  module Entities
    # add description
    class Nested < Attributable
      def self.namespace(name, &block) # rubocop:disable Metrics/MethodLength
        serializable_attributes(name)
        comparable_attributes(name)

        namespace_class = Class.new(Nested)
        namespace_class.define_singleton_method(:name) { "Namespace:#{name}" }
        namespace_class.class_eval(&block)

        anonym_mixin = Module.new do
          attr_reader(name)
          define_method(:"#{name}=") do |input|
            instance_variable_set(:"@#{name}", namespace_class.wrap(input))
          end
        end
        include(anonym_mixin)
      end
    end
  end
end
