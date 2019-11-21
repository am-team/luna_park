# frozen_string_literal: true

module LunaPark
  module Extensions
    module Repositories
      module Sequel
        module Delete
          def delete(uid)
            dataset.returning.where(uid: uid).delete
          end
        end
      end
    end
  end
end
