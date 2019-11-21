# frozen_string_literal: true

require 'webmock/rspec'

module LunaPark
  module Gateways
    module Http
      RSpec.describe RestClient do
        let(:api)    { 'http://example.com/api/test' }
        let(:client) { described_class.new }

        describe '.send_request' do
          let(:title)   { 'Custom request' }
          let(:request) { Requests::Json.new(url: api) }
          let(:handler) { Handlers::Rest.new }

          subject { described_class.send_request title: title, request: request, handler: handler }

          context 'success request' do
            before { stub_request(:post, api) }

            it { expect { subject }.to_not raise_error }
            it { is_expected.to be_an_instance_of ::RestClient::Response }
          end

          context 'bad request' do
            before { stub_request(:post, api).to_return(status: 403) }

            it { expect { subject }.to raise_error Errors::Rest::Diagnostic }
          end

          context 'request shutdown by timeout' do
            before { stub_request(:post, api).to_timeout }

            it { expect { subject }.to raise_error Errors::Rest::Timeout }
          end
        end

        describe '#request' do
          let(:title) { 'Custom request' }
          subject { client.request(title, url: api, method: :patch, body: 'ping') }

          context 'success request' do
            before { stub_request(:patch, api) }

            it { expect { subject }.to_not raise_error }
            it { is_expected.to be_an_instance_of ::RestClient::Response }
          end

          context 'bad request' do
            before { stub_request(:patch, api).to_return(status: 403) }

            it { expect { subject }.to raise_error Errors::Rest::Diagnostic }
          end

          context 'request shutdown by timeout' do
            before { stub_request(:patch, api).to_timeout }

            it { expect { subject }.to raise_error Errors::Rest::Timeout }
          end
        end

        describe '#json_request' do
          let(:title) { 'Custom request' }
          subject { client.json_request(title, url: api, method: :post, body: 'ping') }

          context 'success request' do
            before { stub_request(:post, api) }

            it { expect { subject }.to_not raise_error }
            it { is_expected.to be_an_instance_of ::RestClient::Response }
          end

          context 'bad request' do
            before { stub_request(:post, api).to_return(status: 403) }

            it { expect { subject }.to raise_error Errors::Rest::Diagnostic }
          end

          context 'request shutdown by timeout' do
            before { stub_request(:post, api).to_timeout }

            it { expect { subject }.to raise_error Errors::Rest::Timeout }
          end
        end
      end
    end
  end
end
