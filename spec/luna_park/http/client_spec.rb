# frozen_string_literal: true

require 'luna_park/http/client'

module LunaPark
  RSpec.describe Http::Client do
    let(:client) { described_class.new }

    describe 'plain request' do
      subject(:request) do
        client.plain_request(
          title: 'Get users list',
          url: 'http://api.example.com/users'
        )
      end

      it { is_expected.to be_a Http::Request }

      it 'should has expected structure' do
        expect(request.title).to eq 'Get users list'
        expect(request.url).to eq 'http://api.example.com/users'
        expect(request.method).to eq(:get)
        expect(request.body).to be_nil
        expect(request.headers).to eq('Content-Type': 'application/www-form-urlencoded')
      end
    end

    describe 'json request' do
      subject(:request) do
        client.json_request(
          title: 'Add user',
          url: 'http://api.example.com/users',
          method: :post,
          body: { name: 'John Doe', email: 'john.doe@example.com' }
        )
      end

      it { is_expected.to be_a Http::Request }

      it 'should has expected structure' do
        expect(request.title).to eq 'Add user'
        expect(request.url).to eq 'http://api.example.com/users'
        expect(request.method).to eq(:post)
        expect(request.body).to eq '{"name":"John Doe","email":"john.doe@example.com"}'
        expect(request.headers).to eq('Content-Type': 'application/json')
      end
    end

    shared_examples 'send request' do |request_type|
      let(:response) { double }
      let(:driver)   { double(call: response, call!: response) }
      let(:request)  { Http::Request.new(title: 'Test request', method: :get, url: 'example.com', driver: driver) }

      it 'should send request' do
        expect { subject }.to change(request, :sent?).from(false).to(true)
      end

      it 'should change request method to get' do
        expect { subject }.to change(request, :method).to(request_type)
      end

      it 'should get response' do
        is_expected.to eq response
      end
    end

    describe 'get' do
      it_behaves_like 'send request', :get do
        let(:request)  { Http::Request.new(title: 'Test request', method: :post, url: 'example.com', driver: driver) }
        subject { client.get request }
      end
    end

    describe 'post' do
      it_behaves_like 'send request', :post do
        subject { client.post request }
      end
    end

    describe 'put' do
      it_behaves_like 'send request', :put do
        subject { client.put request }
      end
    end

    describe 'patch' do
      it_behaves_like 'send request', :patch do
        subject { client.patch request }
      end
    end

    describe 'delete' do
      it_behaves_like 'send request', :delete do
        subject { client.delete request }
      end
    end

    describe 'get!' do
      it_behaves_like 'send request', :get do
        let(:request) { Http::Request.new(title: 'Test request', method: :post, url: 'example.com', driver: driver) }
        subject { client.get! request }
      end
    end

    describe 'post!' do
      it_behaves_like 'send request', :post do
        subject { client.post! request }
      end
    end

    describe 'put!' do
      it_behaves_like 'send request', :put do
        subject { client.put! request }
      end
    end

    describe 'patch!' do
      it_behaves_like 'send request', :patch do
        subject { client.patch! request }
      end
    end

    describe 'delete!' do
      it_behaves_like 'send request', :delete do
        subject { client.delete! request }
      end
    end
  end
end
