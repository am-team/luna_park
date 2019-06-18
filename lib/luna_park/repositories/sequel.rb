# frozen_string_literal: true

module LunaPark
  module Repositories
    class Sequel
      include LunaPark::Extensions::DataMapper
    end
  end
end
