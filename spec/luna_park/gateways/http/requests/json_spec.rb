# frozen_string_literal: true

module LunaPark
  module Gateways
    module Http
      module Requests
        RSpec.describe Json do
          let(:method)  { :post }
          let(:url)     { 'http://example.com/api/test' }
          let(:body)    { { foo: 'bar' } }

          let(:request) do
            described_class.new(
              method: method,
              url: url,
              body: body
            )
          end

          describe '.to_h' do
            subject(:hash) { request.to_h }

            it 'should has described structure' do
              is_expected.to eq(
                method: method,
                url: url,
                payload: JSON[body],
                headers: { 'Content-Type': 'application/json' },
                read_timeout: 10,
                open_timeout: 10
              )
            end
          end
        end
      end
    end
  end
end
