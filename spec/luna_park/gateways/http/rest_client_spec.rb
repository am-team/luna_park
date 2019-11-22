# frozen_string_literal: true

require 'webmock/rspec'

require 'luna_park/gateways/http/rest_client'
require 'luna_park/gateways/http/handlers/default'
require 'luna_park/gateways/http/requests/json'

module LunaPark
  module Gateways
    module Http
      RSpec.describe RestClient do
        let(:api)    { 'http://example.com/api/test' }
        let(:client) { described_class.new }

        describe '.send_request' do
          subject(:send_request) { described_class.send_request title: title, request: request, handler: handler }

          let(:title)   { 'Custom request' }
          let(:request) { Requests::Json.new(url: api) }
          let(:handler) { Handlers::Default.new }

          context 'success request' do
            before { stub_request(:post, api) }

            it { expect { send_request }.to_not raise_error }
            it { is_expected.to be_an_instance_of ::RestClient::Response }
          end

          context 'bad request' do
            before { stub_request(:post, api).to_return(status: 403) }

            it { expect { send_request }.to raise_error Errors::Default::Diagnostic }
          end

          context 'request shutdown by timeout' do
            before { stub_request(:post, api).to_timeout }

            it { expect { send_request }.to raise_error Errors::Default::Timeout }
          end
        end

        describe '#request' do
          subject(:request) { client.request(title, url: api, method: :patch, body: 'ping') }

          let(:title) { 'Custom request' }

          context 'success request' do
            before { stub_request(:patch, api) }

            it { expect { request }.to_not raise_error }
            it { is_expected.to be_an_instance_of ::RestClient::Response }
          end

          context 'bad request' do
            before { stub_request(:patch, api).to_return(status: 403) }

            it { expect { subject }.to raise_error Errors::Default::Diagnostic }
          end

          context 'request shutdown by timeout' do
            before { stub_request(:patch, api).to_timeout }

            it { expect { request }.to raise_error Errors::Default::Timeout }
          end
        end

        describe '#json_request' do
          subject(:json_request) { client.json_request(title, url: api, method: :post, body: 'ping') }

          let(:title) { 'Custom request' }

          context 'success request' do
            before { stub_request(:post, api) }

            it { expect { json_request }.to_not raise_error }
            it { is_expected.to be_an_instance_of ::RestClient::Response }
          end

          context 'bad request' do
            before { stub_request(:post, api).to_return(status: 403) }

            it { expect { json_request }.to raise_error Errors::Default::Diagnostic }
          end

          context 'request shutdown by timeout' do
            before { stub_request(:post, api).to_timeout }

            it { expect { json_request }.to raise_error Errors::Default::Timeout }
          end
        end
      end
    end
  end
end
