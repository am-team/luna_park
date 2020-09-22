# frozen_string_literal: true

require 'luna_park/extensions/data_mapper'

module LunaPark
  class Repository
    include LunaPark::Extensions::DataMapper
  end
end
