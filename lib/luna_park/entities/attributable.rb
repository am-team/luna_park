# frozen_string_literal: true

require_relative 'simple'

require_relative '../extensions/comparable'
require_relative '../extensions/serializable'
require_relative '../extensions/dsl/attributes'

module LunaPark
  module Entities
    # add description
    class Attributable < Simple
      include Extensions::Comparable
      include Extensions::Serializable
      extend  Extensions::Dsl::Attributes
    end
  end
end
