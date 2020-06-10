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

        def validator(klass = nil, &block) # rubocop:disable Metrics/MethodLength
          if block_given? && klass.nil?
            warn <<~WARNING
              WARNING! -------------------------------------------------------
              IN         `LunaPark::Extensions::Validatable::Dry`
              DO NOT use `validator do` (with block)
                     USE `dry_validator do` (with block) instead
              ------------------------------------------------------- WARNING!
            WARNING

            return dry_validator(&block)
          end

          super(klass)
        end

        def dry_validator(&block)
          validator Validators::Dry.build(&block)
        end
      end
    end
  end
end
