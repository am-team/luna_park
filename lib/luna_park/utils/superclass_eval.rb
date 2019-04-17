# frozen_string_literal: true

module LunaPark
  module Utils
    ##
    # hack for defining meta-methods with available super methods
    #
    # When you defines Foo.attr_accessor or same dsl that dynamicaly defines methods,
    #   you defines it in your class Foo, so thea have not superclass methods.
    #   So if you want to redefine those methods using `super` - you can't
    #
    # This module allows you to define any methods as methods in anonym mixin
    #   So if you want to redefine those methods using `super` - you can,
    #     if  those methods will be defined in block `superclass_eval`
    #
    # @example
    #   class Foo
    #     attr_accessor :foo
    #     def foo=(input)
    #       super(input.downcase)
    #     end
    #   end
    #   o = Foo.new
    #   o.foo = 'FOO' # => raise Unknown supermethod `foo`
    #
    #   class Bar
    #     extend LunaPark::Utils::SuperclassEval
    #
    #     superclass_eval do
    #       attr_accessor :bar
    #     end
    #
    #     def foo=(input)
    #       super(input.downcase)
    #     end
    #   end
    #
    #   o = Foo.new
    #   o.bar = 'BAR'
    #   o.bar # => 'bar'
    module SuperclassEval
      IVAR = :@__anonym_mixin__

      def superclass_eval(&block)
        SuperclassEval.superclass_eval(self, &block)
      end

      class << self
        def superclass_eval(base, &block)
          anonym_mixin_at(base).class_eval(&block)
        end

        private

        def anonym_mixin_at(base)
          base.instance_variable_get(IVAR) || base.instance_variable_set(IVAR, new_anonym_mixin_at(base))
        end

        def new_anonym_mixin_at(base)
          Module.new.tap { |anonim_mixin| base.include(anonim_mixin) }
        end
      end
    end
  end
end
