# frozen_string_literal: true

module LunaPark
  module Extensions
    module Repositories
      module Postgres
        module Delete
          def delete(pk_value, **scope_opts)
            scoped(**scope_opts).where(primary_key => pk_value).delete.positive?
          end
        end
      end
    end
  end
end
