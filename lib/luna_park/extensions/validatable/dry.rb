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

        def validator(klass = nil, &)
          return super unless block_given?

          klass = Class.new(Validators::Dry)
          klass.validation_schema(&)
          super(klass)
        end
      end
    end
  end
end
