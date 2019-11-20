module GateWay
  module Http
    module Errors
      module Rest
        class Diagnostic < RestClient::Exception
          attr_reader :title, :request, :response

          def initialize(title, request:, response:)
            super(response)
            @title   = title
            @request = request
          end
        end

        class Timeout < RestClient::Timeout
          attr_reader :title, :request

          def initialize(title:, request:)
            super
            @title   = title
            @request = request
          end
        end
      end
    end
  end
end