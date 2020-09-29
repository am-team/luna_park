# frozen_string_literal: true

module LunaPark
  module Tools
    # TODO: add descriptions
    class << self
      def if_gem_installed(name, *requirements)
        Gem::Specification.find_by_name name, *requirements
      rescue Gem::MissingSpecError
        false
      else
        yield if block_given?
        true
      end

      alias gem_installed? if_gem_installed
    end
  end
end
