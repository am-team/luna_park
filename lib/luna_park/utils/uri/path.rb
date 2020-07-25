# frozen_string_literal: true

require 'pathname'

module LunaPark
  module Utils
    class URI
      # `Path` part of `URI`
      #   [http://example.com/foo/bar&baz=bat#42] - URI
      #                     [/foo/bar]            - Path
      # @example
      # # Basic usage
      # path = Path.new('users/42')
      # path + 'orders'  # => "/users/42/orders" # add
      # path + '/orders' # => "/orders"          # (it's logic of Ruby Pathname stdlib: adding root path replaces old path)
      #
      # # "Root" feature
      # path.root?                    # => true        # (because paths starts with "/")
      # Path.new('/users/42').root?   # => true        # (because path started with "/")
      # Path.new('users/42').root?    # => false       # (because path not started with "/")
      # Path.new('/users/42').to_root # => '/users/42' # (already root)
      # Path.new('users/42').to_root  # => '/users/42' # (became root)
      #
      # # Is still a String
      # path = LunaPark::Utils::Path.new('api/v1/users/42').to_root
      # path.is_a?(String)              # => true
      # path.tr('/api/v1/', '/api/v2/') # => "/api/v2/users/42"
      #
      # # Mutations:
      # path << 'additional_path' # same as `#+`,       but will mutate path object
      # path.to_root!             # same as `#to_root`, but will mutate path object
      class Path < String
        attr_reader :pathname

        def self.wrap(input)
          case input
          when self   then input
          when String then new(input)
          when nil    then nil
          else raise LunaPark::Errors::Unwrapable, "#{self} can not wrap #{input.class}"
          end
        end

        def initialize(string)
          super
          self.pathname = string
        end

        def +(other)
          self.class.new((pathname + other).to_s)
        end

        def <<(other)
          self.pathname += other
          replace(pathname.to_s)
        end

        def to_root!
          return self if root?

          self.pathname = "/#{self}"
          replace(pathname.to_s)
        end

        def to_root
          root? ? self : self.class.new("/#{self}")
        end

        def to_subpath!
          return self if subpath?

          self.pathname = self[1..-1]
          replace(pathname.to_s)
        end

        def to_subpath
          subpath? ? self : self.class.new(self[1..-1])
        end

        def subpath?
          !root?
        end

        def root?
          start_with?('/')
        end

        def dup
          self.class.new(self)
        end

        private

        def pathname=(input)
          @pathname = Pathname.new(input)
        end
      end
    end
  end
end
