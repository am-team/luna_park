# frozen_string_literal: true

require 'luna_park/http/response'

module LunaPark
  RSpec.describe Http::Response do
    let(:request) { double }
    let(:params) do
      {
        body: '{"message":"pong"}',
        code: 200,
        headers: { 'Content-Type': 'application/json' },
        cookies: { Secret: 'dkmvc9saudj3cndsaosp' },
        request:
      }
    end

    let(:response) { described_class.new(**params) }

    describe '#body' do
      subject { response.body }

      context 'when defined in initialize method' do
        before { params[:body] = 'defined value' }

        it 'should eq defined value' do
          is_expected.to eq 'defined value'
        end
      end

      context 'when undefined in initialize method' do
        before { params.delete :body }

        it { is_expected.to eq '' }
      end
    end

    describe '#code' do
      subject { response.code }

      context 'when defined in initialize method' do
        before { params[:code] = 404 }

        it 'should eq defined value' do
          is_expected.to eq 404
        end
      end

      context 'when undefined in initialize method' do
        before { params.delete :code }

        it { expect { described_class.new(**params) }.to raise_error ArgumentError }
      end
    end

    describe '#headers' do
      subject { response.headers }

      context 'when defined in initialize method' do
        before { params[:headers] = { 'Accept-Encoding': 'gzip,deflate' } }

        it 'should eq defined value' do
          is_expected.to eq('Accept-Encoding': 'gzip,deflate')
        end
      end

      context 'when undefined in initialize method' do
        before { params.delete :headers }

        it { is_expected.to eq({}) }
      end
    end

    describe '#cookies' do
      subject { response.cookies }

      context 'when defined in initialize method' do
        before { params[:cookies] = { SSID: 'r2t5uvjq435r4q7ib3vtdjq120' } }

        it 'should eq defined value' do
          is_expected.to eq(SSID: 'r2t5uvjq435r4q7ib3vtdjq120')
        end
      end

      context 'when undefined in initialize method' do
        before { params.delete :cookies }

        it { is_expected.to eq({}) }
      end
    end

    describe '#request' do
      let(:request) { double }
      subject       { response.request }

      context 'when defined in initialize method' do
        before { params[:request] = request }

        it 'should eq defined value' do
          is_expected.to eq request
        end
      end

      context 'when undefined in initialize method' do
        before { params.delete :request }

        it { expect { described_class.new(**params) }.to raise_error ArgumentError }
      end
    end

    describe '#inspect' do
      subject { response.inspect }

      it 'should exists code, body, headers and cookies attributes' do
        is_expected.to include '200'
        is_expected.to include 'pong'
        is_expected.to include 'json'
        is_expected.to include 'dkmvc9saudj3cndsaosp'
      end
    end

    describe '#informational_response?' do
      subject { response.informational_response? }

      context 'when code is 1xx' do
        before { params[:code] = 101 }
        it { is_expected.to eq true }
      end

      context 'when code is not 1xx' do
        before { params[:code] = 200 }
        it { is_expected.to eq false }
      end
    end

    describe '#success?' do
      subject { response.success? }

      context 'when code is 2xx' do
        before { params[:code] = 201 }
        it { is_expected.to eq true }
      end

      context 'when code is not 2xx' do
        before { params[:code] = 300 }
        it { is_expected.to eq false }
      end
    end

    describe '#redirection?' do
      subject { response.redirection? }

      context 'when code is 3xx' do
        before { params[:code] = 308 }
        it { is_expected.to eq true }
      end

      context 'when code is not 3xx' do
        before { params[:code] = 400 }
        it { is_expected.to eq false }
      end
    end

    describe '#client_error?' do
      subject { response.client_error? }

      context 'when code is 4xx' do
        before { params[:code] = 422 }
        it { is_expected.to eq true }
      end

      context 'when code is not 4xx' do
        before { params[:code] = 500 }
        it { is_expected.to eq false }
      end
    end

    describe '#server_error?' do
      subject { response.server_error? }

      context 'when code is 5xx' do
        before { params[:code] = 500 }
        it { is_expected.to eq true }
      end

      context 'when code is not 5xx' do
        before { params[:code] = 200 }
        it { is_expected.to eq false }
      end
    end

    describe '#type' do
      subject { response.type }

      context 'when code in 1xx' do
        before { params[:code] = '100' }
        it { is_expected.to eq :informational_response }
      end

      context 'when code in 2xx' do
        before { params[:code] = '200' }
        it { is_expected.to eq :success }
      end

      context 'when code in 3xx' do
        before { params[:code] = '300' }
        it { is_expected.to eq :redirection }
      end

      context 'when code in 4xx' do
        before { params[:code] = '400' }
        it { is_expected.to eq :client_error }
      end

      context 'when code in 5xx' do
        before { params[:code] = '500' }
        it { is_expected.to eq :server_error }
      end

      context 'when code not in 1xx - 5xx' do
        before { params[:code] = '0' }
        it { is_expected.to eq :unknown }
      end
    end

    describe '#status' do
      subject { response.status }
      context 'when get defined status' do
        before { params[:code] = 422 }

        it 'should return status description' do
          is_expected.to eq 'Unprocessable Entity'
        end
      end

      context 'when get defined status' do
        before { params[:code] = 0 }

        it { is_expected.to eq 'Unknown' }
      end
    end

    describe '#json_parse!' do
      subject(:parse_json!) { response.json_parse! }

      context 'when the response body is encoded json' do
        before { params[:body] = '{"version": 1, "data":{"message":"pong"}}' }

        it 'should return hash of parsed whole body' do
          is_expected.to eq(
            version: 1,
            data: { message: 'pong' }
          )
        end

        context 'when defined existed payload_key as symbol' do
          subject(:parse_json!) { response.json_parse! payload_key: :data }

          it 'should return hash only of payload' do
            is_expected.to eq(message: 'pong')
          end
        end

        context 'when defined existed payload_key as string' do
          subject(:parse_json!) { response.json_parse! payload_key: 'data' }

          it 'should return hash only of payload' do
            is_expected.to eq(message: 'pong')
          end
        end

        context 'when defined not existed payload_key' do
          subject(:parse_json!) { response.json_parse! payload_key: :attributes }

          it { expect { parse_json! }.to raise_error LunaPark::Errors::JsonParse }
        end

        context 'when expect get hash keys as strings' do
          subject(:parse_json!) { response.json_parse! stringify_keys: true }

          it 'should return hash of parsed whole body' do
            is_expected.to eq(
              'version' => 1,
              'data' => { 'message' => 'pong' }
            )
          end
        end
      end

      context 'when response body is not json' do
        before { params[:body] = 'pong' }

        it { expect { parse_json! }.to raise_error LunaPark::Errors::JsonParse }
      end
    end

    describe '#json_parse' do
      subject(:parse_json) { response.json_parse }

      context 'when the response body is encoded json' do
        before { params[:body] = '{"version": 1, "data":{"message":"pong"}}' }

        it 'should return hash of parsed whole body' do
          is_expected.to eq(
            version: 1,
            data: { message: 'pong' }
          )
        end

        context 'when defined existed payload_key as symbol' do
          subject(:parse_json) { response.json_parse payload_key: :data }

          it 'should return hash only of payload' do
            is_expected.to eq(message: 'pong')
          end
        end

        context 'when defined existed payload_key as string' do
          subject(:parse_json) { response.json_parse payload_key: 'data' }

          it 'should return hash only of payload' do
            is_expected.to eq(message: 'pong')
          end
        end

        context 'when defined not existed payload_key' do
          subject(:parse_json) { response.json_parse payload_key: :attributes }

          it { is_expected.to be_nil }
        end

        context 'when expect get hash keys as strings' do
          subject(:parse_json) { response.json_parse stringify_keys: true }

          it 'should return hash of parsed whole body' do
            is_expected.to eq(
              'version' => 1,
              'data' => { 'message' => 'pong' }
            )
          end
        end
      end

      context 'when response body is not json' do
        before { params[:body] = 'pong' }

        it { is_expected.to be_nil }
      end
    end

    describe '#to_h' do
      let(:request_hash) { double }
      subject { response.to_h }

      before { allow(request).to receive(:to_h).and_return(request_hash) }

      it 'should return hash in expected format' do
        is_expected.to eq(
          body: '{"message":"pong"}',
          code: 200,
          headers: { 'Content-Type': 'application/json' },
          cookies: { Secret: 'dkmvc9saudj3cndsaosp' },
          request: request_hash
        )
      end
    end
  end
end
