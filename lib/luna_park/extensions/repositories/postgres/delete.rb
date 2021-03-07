# frozen_string_literal: true

module LunaPark
  module Extensions
    module Repositories
      module Postgres
        module Delete
          def delete(input)
            dataset.returning.where(wrap_pk_to_record(input)).delete
          end
        end
      end
    end
  end
end
