# frozen_string_literal: true

module LunaPark
  module CLI
    module Errors
      class CouldNotCreateDir < LunaPark::Errors::Processing; end
      class CouldNotSaveFile  < LunaPark::Errors::Processing; end
    end
  end
end
