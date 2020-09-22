# frozen_string_literal: true

require 'luna_park/repository'

module LunaPark
  module Repositories
    # DEPRECATED! Use LunaPark::Repository instead
    # @deprecated
    class Sequel < LunaPark::Repository; end
  end
end
