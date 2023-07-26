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

        def validator(*args, &block)
          return super unless block_given?

          klass = Class.new(Validators::Dry)
          klass.validation_schema(&block)
          super(*args, klass)
        end
      end
    end
  end
end
