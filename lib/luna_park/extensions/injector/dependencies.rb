# frozen_string_literal: true

module LunaPark
  module Extensions
    module Injector
      ##
      # Hash for define dependencies in {Injector} extension.
      #
      # Main difference between Hash and Dependencies it is memorization;
      #
      #   # hash example
      #   i = 0
      #
      #   hash = { i: -> { i += 1 } }
      #   hash[:i].call # => 1
      #   hash[:i].call # => 2
      #
      #   # dependencies
      #   i = 0
      #
      #   dependencies =  Dependencies.wrap(i: -> { i += 1 })
      #   dependencies.call_with_cache(:i) # => 1
      #   dependencies.call_with_cache(:i) # => 1
      #
      class Dependencies < Hash
        class << self
          ##
          # Dependencies.try_convert(obj) -> hash or nil
          #
          # Try to convert obj into a hash, using to_hash method.
          # Returns converted hash or nil if obj cannot be converted
          # for any reason.
          #
          # See {Hash.try_convert}[https://ruby-doc.org/core-2.7.2/Hash.html#method-c-try_convert]
          #
          #    Dependencies.try_convert({1=>2})   # => {1=>2}
          #    Dependencies.try_convert("1=>2")   # => nil
          def try_convert(obj)
            super.nil? ? nil : new.replace(super)
          end

          alias wrap try_convert
        end

        ##
        #  Run dependency code and cache result.
        #
        #    use_case.dependencies[:messenger] # => #<Proc:0x0000564a0d90d438@t.rb:34>
        #    use_case.dependencies.call_with_cache(:messenger) # => 'Foobar'
        def call_with_cache(key)
          cache[key] ||= self[key].call
        end

        def []=(key, _val)
          cache[key] = nil
          super
        end

        private

        def cache
          @cache ||= {}
        end
      end

      # @!parse include Injector::ClassMethods
      # @!parse extend Injector::InstanceMethods
      def self.included(base)
        base.extend ClassMethods
        base.include InstanceMethods
      end
    end
  end
end
