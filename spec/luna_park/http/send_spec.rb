# frozen_string_literal: true

require 'webmock/rspec'
require 'luna_park/http/send'

module LunaPark
  RSpec.describe Http::Send do
    let(:request) do
      double(
        url: 'http://example.com',
        method: :post,
        body: '{"message":"ping"}',
        headers: { 'Content-Type': 'application/json' },
        open_timeout: 5,
        read_timeout: 5
      )
    end

    describe '#call' do
      subject(:send) { described_class.new(request).call }

      before { stub_request(:any, 'http://example.com') }

      it 'should send defined http request' do
        send
        expect(WebMock).to have_requested(:post, 'http://example.com')
          .with(
            body: JSON.generate(message: 'ping'),
            headers: { 'Content-Type': 'application/json' }
          )
      end

      context 'when server return success response' do
        before do
          stub_request(:any, 'http://example.com')
            .to_return(
              body: '{"message":"pong"}',
              status: 200,
              headers: {
                'Content-Type': 'application/json',
                'Set-Cookie': 'theme=light'
              }
              # cookies: {example: 42}
            )
        end

        it 'should get expected response' do
          is_expected.to eq Http::Response.new(
            code: 200,
            body: '{"message":"pong"}',
            headers: {
              content_type: 'application/json',
              set_cookie: ['theme=light']
            },
            cookies: { 'theme' => 'light' },
            request:
          )
        end
      end

      context 'when server return failed response' do
        before do
          stub_request(:any, 'http://example.com')
            .to_return(
              body: '{"error":"Something went wrong"}',
              status: 400,
              headers: {
                'Content-Type': 'application/json'
              }
            )
        end

        it 'should get failed response' do
          is_expected.to eq Http::Response.new(
            code: 400,
            body: '{"error":"Something went wrong"}',
            headers: {
              content_type: 'application/json'
            },
            cookies: {},
            request:
          )
        end
      end

      context 'when server is down' do
        before do
          stub_request(:any, 'http://example.com').to_raise(Errno::ECONNREFUSED)
        end

        it 'should get response with 503' do
          is_expected.to eq Http::Response.new(code: 503, request:)
        end
      end

      context 'when server get open timeout' do
        before { stub_request(:any, 'http://example.com').to_raise(Net::OpenTimeout) }

        it 'should get response with 408' do
          is_expected.to eq Http::Response.new(code: 408, request:)
        end
      end

      context 'when server get read timeout' do
        before { stub_request(:any, 'http://example.com').to_raise(Net::ReadTimeout) }

        it 'should get response with 408' do
          is_expected.to eq Http::Response.new(code: 408, request:)
        end
      end
    end

    describe '#call!' do
      subject(:send!) { described_class.new(request).call! }

      before { stub_request(:any, 'http://example.com') }

      it 'should send! defined http request' do
        send!
        expect(WebMock).to have_requested(:post, 'http://example.com')
          .with(
            body: JSON.generate(message: 'ping'),
            headers: { 'Content-Type': 'application/json' }
          )
      end

      context 'when server return success response' do
        before do
          stub_request(:any, 'http://example.com')
            .to_return(
              body: '{"message":"pong"}',
              status: 200,
              headers: {
                'Content-Type': 'application/json',
                'Set-Cookie': 'theme=light'
              }
            )
        end

        it 'should get expected response' do
          is_expected.to eq Http::Response.new(
            code: 200,
            body: '{"message":"pong"}',
            headers: {
              content_type: 'application/json',
              set_cookie: ['theme=light']
            },
            cookies: { 'theme' => 'light' },
            request:
          )
        end
      end

      context 'when server return failed response' do
        before do
          stub_request(:any, 'http://example.com')
            .to_return(
              body: '{"error":"Something went wrong"}',
              status: 400,
              headers: { 'Content-Type': 'application/json' }
            )
        end

        it 'should raise http exception' do
          expected_response = Http::Response.new(
            code: 400,
            body: '{"error":"Something went wrong"}',
            headers: {
              content_type: 'application/json'
            },
            request:
          )

          expect { send! }.to raise_error(
            an_instance_of(Errors::Http).and(having_attributes(
                                               message: 'Bad Request',
                                               response: expected_response
                                             ))
          )
        end
      end

      context 'when server is down' do
        before do
          stub_request(:any, 'http://example.com').to_raise(Errno::ECONNREFUSED)
        end

        it 'should raise http exception with 503 error code response' do
          expected_response = Http::Response.new(code: 503, request:)

          expect { send! }.to raise_error(
            an_instance_of(Errors::Http).and(having_attributes(
                                               message: 'Service Unavailable',
                                               response: expected_response
                                             ))
          )
        end
      end

      context 'when server get open timeout' do
        before { stub_request(:any, 'http://example.com').to_raise(Net::OpenTimeout) }

        it 'should raise http exception with 408 error code response' do
          expected_response = Http::Response.new(code: 408, request:)

          expect { send! }.to raise_error(
            an_instance_of(Errors::Http).and(having_attributes(
                                               message: 'Request Timeout',
                                               response: expected_response
                                             ))
          )
        end
      end

      context 'when server get read timeout' do
        before { stub_request(:any, 'http://example.com').to_raise(Net::ReadTimeout) }

        it 'should raise http exception with 408 error code response' do
          expected_response = Http::Response.new(code: 408, request:)

          expect { send! }.to raise_error(
            an_instance_of(Errors::Http).and(having_attributes(
                                               message: 'Request Timeout',
                                               response: expected_response
                                             ))
          )
        end
      end
    end
  end
end
