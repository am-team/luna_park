# frozen_string_literal: true

module Foo
  class << self
    def bar
      123
    end
  end
end

puts Foo.bar
