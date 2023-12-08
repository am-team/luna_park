# frozen_string_literal: true

module LunaPark
  module Extensions
    module Repositories
      module Postgres
        module Delete
          def delete(input, **scope_opts)
            case input
            when self.class.entity_class then pk_value = input.public_send(primary_key)
            when Hash                    then pk_value = input[primary_key]
            else pk_value = input
            end

            raise ArgumentError, "primary key '#{primary_key}' value can't be nil" if pk_value.nil?

            scoped(**scope_opts).where(primary_key => pk_value).delete.positive?
          end
        end
      end
    end
  end
end
