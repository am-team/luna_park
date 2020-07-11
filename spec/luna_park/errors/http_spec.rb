# frozen_string_literal: true

require 'luna_park/http/request'
require 'luna_park/http/response'
require 'luna_park/errors/http'

I18n.load_path << Dir['spec/locales/*.yml']

module LunaPark
  RSpec.describe Errors::Http do
    describe '#initialize' do
      context 'when use wrong type of request' do
        it { expect { described_class.new response: :undefined }.to raise_error ArgumentError }
      end
    end

    describe '#response' do
      let(:response) { double }
      let(:error)    { described_class.new response: response }
      subject { error.response }

      before do
        allow(response).to receive(:is_a?).with(Http::Response) { true }
      end

      it 'should be eq response defined in constructor of class' do
        is_expected.to eq response
      end
    end

    describe '#request' do
      let(:request) { double }
      let(:response) { double request: request }
      let(:error) { described_class.new response: response }

      subject { error.request }

      before do
        allow(response).to receive(:is_a?).with(Http::Response) { true }
      end

      it 'should be eq request which call response defined in constructor of class' do
        is_expected.to eq request
      end
    end

    describe '#details' do
      let(:request) do
        Http::Request.new(
          title: 'Ping-pong',
          method: :post,
          url: 'http://example.com/api/ping',
          body: JSON.generate(message: 'ping'),
          headers: { 'Content-Type': 'application/json' }
        )
      end

      let(:response) do
        Http::Response.new(
          body: '{"message":"pong"}',
          code: 200,
          headers: { 'Content-Type': 'application/json' },
          cookies: { 'Secret': 'dkmvc9saudj3cndsaosp' },
          request: request
        )
      end

      let(:error) { described_class.new 'Custom message', response: response, something: 'important' }

      subject { error.details }

      it 'should return formatted details' do
        is_expected.to eq(
          title: 'Ping-pong',
          status: 'OK',
          request: {
            body: '{"message":"ping"}',
            method: :post,
            headers: { 'Content-Type': 'application/json' },
            open_timeout: 10,
            read_timeout: 10,
            sent_at: nil,
            url: 'http://example.com/api/ping'
          },
          response: {
            body: '{"message":"pong"}',
            code: 200,
            headers: { 'Content-Type': 'application/json' },
            cookies: { 'Secret': 'dkmvc9saudj3cndsaosp' }
          },
          error_details: { something: 'important' }
        )
      end
    end
  end
end
