# frozen_string_literal: true

require 'luna_park/validators/dry'

module LunaPark
  module Extensions
    module Validatable
      module Dry
        def self.included(base)
          base.include Validatable
          base.extend  self
        end

        def validator(klass = nil, &block)
          return super(Validators::Dry.build(&block)) if block_given? && klass.nil?

          super(klass)
        end
      end
    end
  end
end
