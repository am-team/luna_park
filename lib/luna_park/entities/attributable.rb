# frozen_string_literal: true

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
