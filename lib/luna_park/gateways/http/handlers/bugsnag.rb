# frozen_string_literal: true

require 'luna_park/gateways/http/errors/bugsnag'

module LunaPark
  module Gateways
    module Http
      module Handlers
        class Bugsnag
          attr_reader :skip_errors

          def initialize(skip_errors: [])
            @skip_errors = skip_errors
          end

          def error(title, request:, response:)
            unless skip_errors.include? response.code # rubocop:disable Style/GuardClause
              raise Errors::Bugsnag::Diagnostic.new(title, response: response, request: request)
            end
          end

          def timeout_error(title, request:)
            raise Errors::Bugsnag::Timeout.new(title, request: request) unless skip_errors.include?(:timeout)
          end
        end
      end
    end
  end
end
