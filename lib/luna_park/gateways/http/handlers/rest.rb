# frozen_string_literal: true
module LunaPark
  module Gateways
    module Http
      module Handlers
        class Rest
          attr_reader :skip_errors

          def initialize(skip_errors: [])
            @skip_errors = []
          end

          def catch(title: '', request:)
            yield
          rescue RestClient::Exception => e
            error(title, exception: e, request: request)
          rescue RestClient::Exceptions::Timeout
            timeout_error(title, request: request)
          end

          private

          def error(title, exception:, request:)
            unless skip_errors.include? error.response.try(:code) do
              raise Errors::Diagnostic, title, request:  request,
                                               response: exception.response
            end
          end

          def timeout_error(title, request:)
            unless skip_errors.include? :timeout do
              raise Errors::Timeout, title, request: request
            end
          end
        end
      end
    end
  end
end
