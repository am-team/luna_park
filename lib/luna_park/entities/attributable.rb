# frozen_string_literal: true

require 'luna_park/entities/simple'

require 'luna_park/extensions/comparable'
require 'luna_park/extensions/serializable'
require 'luna_park/extensions/dsl/attributes'
require 'luna_park/extensions/dsl/foreign_key'

module LunaPark
  module Entities
    # add description
    class Attributable < Simple
      include Extensions::Comparable
      include Extensions::Serializable
      extend  Extensions::Dsl::Attributes
      extend  Extensions::Dsl::ForeignKey
    end
  end
end
