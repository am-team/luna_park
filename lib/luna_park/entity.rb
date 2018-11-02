# frozen_string_literal: true

require_relative 'extensions/comparsionable'
require_relative 'extensions/comparsionable_debug'

module LunaPark
  class Entity
    include Extensions::Comparsionable
    include Extensions::ComparsionableDebug

    class << self
      def namespace(name, &block)
        fields_to_h       << name
        fields_comparsion << name

        namespace_class = Class.new(Entity)
        namespace_class.define_singleton_method(:name) { "Namespace:#{name}" }
        namespace_class.class_eval(&block)

        attr_reader(name)
        define_method(:"#{name}=") do |input|
          instance_variable_set(:"@#{name}", namespace_class.wrap(input))
        end
      end

      def attr(name, klass = nil, method = nil, comparsion: true)
        fields_to_h       << name
        fields_comparsion << name if comparsion
        attr_reader(name)

        if klass.nil? && method.nil?
          attr_writer(name)
        else
          define_method(:"#{name}=") do |input|
            instance_variable_set(:"@#{name}", klass.public_send(method, input))
          end
        end
      end

      def wrap(input)
        case input
        when self then input
        when Hash then new(input)
        else raise ArgumentError, "Can`t wrap #{attrs.class}"
        end
      end

      def fields_to_h
        @fields_to_h ||= []
      end

      def fields_comparsion
        @fields_comparsion ||= []
      end
    end

    def initialize(hash)
      hash.each { |k, v| public_send(:"#{k}=", v) }
    end

    HASHEABLE = ->(o) { o.respond_to?(:to_h) }.freeze

    def to_h
      self.class
          .fields_to_h
          .each_with_object({}) do |field, output|
            value = public_send(field)
            next if value.nil?

            output[field] =
              case value
              when HASHEABLE then value.to_h
              when Array     then value.map(&:to_h)
              when Hash      then value.transform_values(&:to_h)
              else value
              end
          end
    end

    def inspect
      attrs = self.class.fields_to_h.map do |field|
        value = send(field)
        "@#{field}=#{value.inspect}" if value
      end
      "#<#{self.class.name} #{attrs.compact.join(' ')}>"
    end

    private

    def comparsion_attributes
      self.class.fields_comparsion
    end
  end
end
