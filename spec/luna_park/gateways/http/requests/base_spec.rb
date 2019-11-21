# frozen_string_literal: true

module LunaPark
  module Gateways
    module Http
      module Requests
        RSpec.describe Base do
          let(:method)  { :post }
          let(:url)     { 'http://example.com/api/test' }
          let(:body)    { 'foo' }
          let(:headers) { 'headers' }

          let(:request) do
            described_class.new(
              method: method,
              url: url,
              body: body,
              headers: headers
            )
          end

          describe '.to_h' do
            subject { request.to_h }

            it 'should has described structure' do
              is_expected.to eq(
                method: method,
                url: url,
                payload: body,
                headers: headers,
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
