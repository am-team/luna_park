# frozen_string_literal: true

module LunaPark
  module Tools
    # TODO: add descriptions
    def self.if_gem_installed(name, *requirements)
      Gem::Specification.find_by_name name, *requirements
    rescue Gem::MissingSpecError
      false
    else
      yield
      true
    end
  end
end
