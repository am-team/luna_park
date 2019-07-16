# frozen_string_literal: true

require_relative '../comparable'
require_relative '../serializable'
require_relative '../predicate_attr_accessor'
require_relative '../typed_attr_accessor'

module LunaPark
  module Extensions
    module Dsl
      ##
      # class-level mixin
      #
      # @example
      #   class Elephant
      #     include LunaPark::Extensions::Comparable   # required for Dsl::Attributes
      #     include LunaPark::Extensions::Serializable # required for Dsl::Attributes
      #     extend  LunaPark::Extensions::Dsl::Attributes
      #
      #     # ...
      #
      #     attr  :eyes_count                        # simple accessor registered as serializable and comparable attribute
      #     attr  :ears, Ears, :new                  # :new or any other class method that will construct Ear object
      #     attr  :defeat_enemies, comparable: false # will not be used in compasrion via `#==``
      #     attr? :alive                             # will add predicate? method
      #
      #     attr_accessor :smuggler
      #
      #     # ...
      #   end
      #
      #   e1 = Elephant.new(eyes_count: 1, ears: { left: true, right: true }, defeat_enemies: 228, alive: true, smuggler: true)
      #   e2 = Elephant.new(eyes_count: 1, ears: { left: true, right: true }, defeat_enemies: 0, alive: true, smuggler: false)
      #   e3 = Elephant.new(eyes_count: 2, ears: { left: true, right: true }, defeat_enemies: 0, alive: true, smuggler: true)
      #
      #   e1 == e2 # => true  (comparsion disabled for #defeat_enemies and not registered for #smuggler)
      #   e1 == e3 # => false (missmatch of #eyes_count)
      #
      #   e1.to_h # => { eyes_count: 1, ears: { left: true, right: true }, defeat_enemies: 228, alive: true }
      #           #    (omit #smuggler cause it's not registered for serialization)
      #
      #   e1.ears # => #<Ears left=true right=true>
      #   e1.ears = { left: true, right: false }
      #   e1.ears # => #<Ears left=true right=false>
      #
      #   e1.alive? # => true
      module Attributes
        DEFAULT_TYPE_METH = :call
        private_constant :DEFAULT_TYPE_METH

        include PredicateAttrAccessor
        include TypedAttrAccessor

        ##
        # .attr that also adds `reader?`
        #
        # @return [Array of Hash(Symbol => Symbol)] Hash of defined methods
        def attrs?(*args, **options)
          defined_methods_arr = attrs(*args, **options)
          getter_names = defined_methods_arr.map { |r| r[:getter] }

          protected(*getter_names)
          attr_reader?(*getter_names)

          defined_methods_arr.map { |r| r.merge(predicate: :"#{r[:getter]}?") }
        end

        ##
        # .attrs that also adds `reader?`
        #   return Hash of defined methods `{ getter: :foo, setter: :foo=, predicate }`
        #
        # @return [Hash(Symbol => Symbol)] Hash of defined methods
        def attr?(*args, **options)
          defined_methods = attr(*args, **options)
          getter_name = defined_methods[:getter]

          protected(getter_name)
          attr_reader?(getter_name)

          defined_methods.merge(predicate: :"#{getter_name}?")
        end

        ##
        # .attr with mass defining
        #
        # @example
        #   attrs name1, name2, name3, **attr_options
        #   attrs name1, name2, name3, CallableType, **attr_options
        #   attrs name1, name2, name3, Type, :type_method, **attr_options
        #
        # @return [Array of Hash(Symbol => Symbol)] Hash of defined methods
        def attrs(*args, **options) # rubocop:disable Metrics/MethodLength
          *names, type, type_meth = if args.all? { |arg| arg.is_a?(Symbol) }
                                      [*args, nil, nil]
                                    elsif args[0..-2].all? { |arg| arg.is_a?(Symbol) }
                                      [*args, DEFAULT_TYPE_METH]
                                    elsif args[0..-3].all? { |arg| arg.is_a?(Symbol) } && args.last.is_a?(Symbol)
                                      args
                                    else
                                      raise ArgumentError, 'must be (*names) | ' \
                                        '(*names, type) | (*names, type, type_meth)'
                                    end

          names.map { |name| attr name, type, type_meth, **options }
        end

        ##
        # define typed attr_accessor, register it for Extenions::Comparable, Extenions::Serializable
        #   so it will be comparable using `#==`, `#eql?` and serializable using `#to_h`, `#serialize`
        #   return Hash of defined methods `{ getter: :foo, setter: :foo= }`
        #
        # @param name [Symbol]
        # @param type [Object] any object that responds to method described in next param. Skip if you dont need stypification
        # @param method [Symbol] (call)
        # @option options [Bool] comparable (true)
        # @option options [Bool] array (false)
        # @option options [Bool] private_setter (false)
        #
        # @return [Hash(Symbol => Symbol)]
        #   Hash of defined methods { :method_role => :method_name }; `{ getter: :foo }`
        def attr(name, type = nil, type_meth = nil, comparable: true, array: false)
          type_meth ||= DEFAULT_TYPE_METH
          attr_reader(name)

          serializable_attributes(name) if include?(Serializable)
          comparable_attributes(name)   if comparable && include?(Comparable)

          typed_attr_writer(name, type&.method(type_meth), is_array: array)

          { getter: name, setter: :"#{name}=" }
        end

        def attributes_list
          return @attributes_list if @attributes_list

          raise Errors::NotConfigured,
                "You must set at least one attribute using #{self}.attr(name, type = nil, type_method = :call)"
        end
      end
    end
  end
end
