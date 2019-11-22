# frozen_string_literal: true

require 'luna_park/repository'
require 'luna_park/extensions/data_mapper'

module LunaPark
  module Repositories
    # DEPRECATED! Use LunaPark::Repository instead
    # @deprecated
    class Sequel < LunaPark::Repository; end
  end
end
