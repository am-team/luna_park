# frozen_string_literal: true

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
        DEFAULT_COERCER_METH = :call
        private_constant :DEFAULT_COERCER_METH

        include PredicateAttrAccessor
        include CoercibleAttrAccessor

        ##
        # .attr that also adds `reader?`
        #
        # @return [Array of Hash(Symbol => Symbol)] Hash of defined methods
        def attrs?(*args, **options)
          results = attrs(*args, **options)
          getter_names = results.map { |r| r[:getter] }

          protected(*getter_names)
          attr_reader?(*getter_names)

          results.map { |r| r.merge(predicate: :"#{r[:getter]}?") }
        end

        ##
        # .attrs that also adds `reader?`
        #   return Hash of defined methods `{ getter: :foo, setter: :foo=, predicate }`
        #
        # @return [Hash(Symbol => Symbol)] Hash of defined methods
        def attr?(*args, **options)
          result = attr(*args, **options)
          getter_name = result[:getter]

          protected(getter_name)
          attr_reader?(getter_name)

          result.merge(predicate: :"#{getter_name}?")
        end

        ##
        # .attr with mass defining
        #
        # @example
        #   attrs name1, name2, name3, **attr_options
        #   attrs name1, name2, name3, CallableCoercer, **attr_options
        #   attrs name1, name2, name3, Coercer, :coerce_method, **attr_options
        #
        # @return [Array of Hash(Symbol => Symbol)] Hash of defined methods
        def attrs(*args, **options)
          *names, coercer, coercer_meth = if args.last.respond_to?(DEFAULT_COERCER_METH)
                                            [*args, DEFAULT_COERCER_METH]
                                          elsif args[-1].is_a?(Symbol) && args[-2].respond_to?(args[-1])
                                            args
                                          else
                                            [*args, nil, nil]
                                          end

          names.map { |name| attr name, coercer, coercer_meth, **options }
        end

        ##
        # define coercible attr_accessor, register it for Extenions::Comparable, Extenions::Serializable
        #   so it will be comparable using `#==`, `#eql?` and serializable using `#to_h`, `#serialize`
        #   return Hash of defined methods `{ getter: :foo, setter: :foo= }`
        #
        # @param name [Symbol]
        # @param type [Object] any object that responds to method described in next param. Skip if you dont need coercion
        # @param method [Symbol] (call)
        # @option options [Bool] comparable (true)
        # @option options [Bool] array (false)
        # @option options [Bool] private_setter (false)
        #
        # @return [Hash(Symbol => Symbol)]
        #   Hash of defined methods { :method_role => :method_name }; `{ getter: :foo }`
        def attr(name, coercer = nil, coercer_meth = nil, comparable: true, array: false)
          coercer_meth ||= DEFAULT_COERCER_METH
          attr_reader(name)

          serializable_attributes(name) if include?(Serializable)
          comparable_attributes(name)   if comparable && include?(Comparable)

          if coercer
            coercible_attr_writer(name, coercer.method(coercer_meth), is_array: array)
          else
            attr_writer(name)
          end

          { getter: name, setter: "#{name}=" }
        end
      end
    end
  end
end
