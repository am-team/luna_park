# frozen_string_literal: true

require 'luna_park/repository'
require 'luna_park/extensions/repositories/postgres/create'
require 'luna_park/extensions/repositories/postgres/read'
require 'luna_park/extensions/repositories/postgres/update'
require 'luna_park/extensions/repositories/postgres/delete'

module LunaPark
  module Repositories
    class Postgres < LunaPark::Repository
      # Extend your repository class with existed mixins
      # @example
      #  class Repo < LunaPark::Repositories::Postgres
      #    mixins :create, :delete
      #
      #    entity Entities::User
      #    mapper Mappers::User
      #  end
      #
      #  user = Entities::User
      #  repo = Repo.new
      #  repo.create user
      #
      # @param list [Array,Symbol] list of mixins, possible values: :create, :read, :update, :delete
      # @return nil
      class << self
        def mixins(*list)
          include Extensions::Repositories::Postgres::Create if list.include? :create
          include Extensions::Repositories::Postgres::Read   if list.include? :read
          include Extensions::Repositories::Postgres::Update if list.include? :update
          include Extensions::Repositories::Postgres::Delete if list.include? :delete
          nil
        end
      end
    end
  end
end
