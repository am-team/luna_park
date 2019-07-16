# frozen_string_literal: true

require_relative '../extensions/data_mapper'

module LunaPark
  module Repositories
    class Sequel
      include LunaPark::Extensions::DataMapper
    end
  end
end
