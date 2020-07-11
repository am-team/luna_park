# frozen_string_literal: true

require 'luna_park/http/request'
require 'timecop'

module LunaPark
  RSpec.describe Http::Request do
    let(:response) { double }
    let(:driver)   { double(call: response, call!: response) }

    let(:request) do
      described_class.new(
        title: 'Get users',
        method: :get,
        url: 'http://example.com',
        body: JSON.generate(message: 'ping'),
        headers: { 'Content-Type': 'application/json' },
        driver: driver
      )
    end

    shared_examples 'mutable argument before request send' do |arg|
      context 'until the request has been sent' do
        let(:new_value) { double :new_value }

        it 'you can change it' do
          expect { request.send(:"#{arg}=", new_value) }.to change { request.send(:"#{arg}") }.to(new_value)
        end
      end

      context 'after the request have been sent' do
        let(:new_value) { double :new_value }
        before { request.call }

        it 'you can not change it' do
          expect { request.send(:"#{arg}=", new_value) }.to raise_error FrozenError
        end
      end
    end

    describe '#title' do
      it 'should be defined in new request instance' do
        expect { described_class.new(method: :get, url: 'http://example.com') }.to raise_error ArgumentError
      end

      it_behaves_like 'mutable argument before request send', :title
    end

    describe '#method' do
      it 'should be defined in new request instance' do
        expect { described_class.new(title: 'Get users', url: 'http://example.com') }.to raise_error ArgumentError
      end

      it_behaves_like 'mutable argument before request send', :method
    end

    describe '#url' do
      it 'should be defined in new request instance' do
        expect { described_class.new(title: 'Get users', method: :get) }.to raise_error ArgumentError
      end

      it_behaves_like 'mutable argument before request send', :url
    end

    describe '#body' do
      it 'if undefined is nil' do
        expect(request.body).to eq '{"message":"ping"}'
      end

      it_behaves_like 'mutable argument before request send', :body
    end

    describe '#headers' do
      it 'if undefined is empty hash' do
        expect(request.headers).to eq('Content-Type': 'application/json')
      end

      it_behaves_like 'mutable argument before request send', :headers
    end

    describe '#open_timeout' do
      it 'if undefined is empty hash' do
        expect(request.open_timeout).to eq(10)
      end

      it_behaves_like 'mutable argument before request send', :open_timeout
    end

    describe '#read_timeout' do
      it 'if undefined is empty hash' do
        expect(request.read_timeout).to eq(10)
      end

      it_behaves_like 'mutable argument before request send', :read_timeout
    end

    describe '#sent_at' do
      subject(:sent_at) { request.sent_at }
      it 'if undefined is empty hash' do
        is_expected.to be_nil
      end

      context 'after the request have been sent' do
        before do
          Timecop.freeze
          request.call!
        end

        it 'should eq current time' do
          is_expected.to eq Time.now
        end

        after { Timecop.return }
      end
    end

    describe '#call' do
      subject(:call) { request.call }

      it 'should send request' do
        expect(driver).to receive(:call).with(request).and_return(response)
        call
      end
    end

    describe '#call!' do
      subject(:call!) { request.call! }

      it 'should send request' do
        expect(driver).to receive(:call!).with(request).and_return(response)
        call!
      end
    end

    describe '#dup' do
      subject(:duplicate) { request.dup }
      before { request.call }

      it 'should reset send time' do
        expect(request.sent_at).is_a? Time
        expect(duplicate.sent_at).to be_nil
      end
    end

    describe '#sent?' do
      subject { request.sent? }

      context 'before send request' do
        it { is_expected.to be false }
      end

      context 'after send request' do
        before { request.call }
        it { is_expected.to be true }
      end
    end

    describe '#driver' do
      subject { request.driver }

      context 'does not specify' do
        let(:request) { Http::Request.new(title: 'Example', method: :get, url: 'http://yandex.ru') }

        it { is_expected.to eq LunaPark::Http::Send }
      end

      context 'specify at class' do
        class Driver; end

        let(:request_class) do
          Class.new(described_class) { driver Driver }
        end

        let(:request) { request_class.new(title: 'Example', method: :get, url: 'http://yandex.ru') }

        it 'should be expected driver' do
          is_expected.to eq Driver
        end
      end

      context 'specify at initialize' do
        class Driver; end
        let(:request) { Http::Request.new(title: 'Example', method: :get, url: 'http://yandex.ru', driver: Driver) }

        it 'should be expected driver' do
          is_expected.to eq Driver
        end
      end
    end

    describe '#inspect' do
      before do
        Timecop.freeze
        request.call!
      end

      subject { request.inspect }

      it 'should exists all attributes' do
        is_expected.to include 'Get users'
        is_expected.to include 'get'
        is_expected.to include 'example.com'
        is_expected.to include 'ping'
        is_expected.to include 'json'
        is_expected.to include Time.now.to_s
      end

      after { Timecop.return }
    end

    describe '#to_h' do
      subject { request.to_h }

      it 'should return hash in expected format' do
        is_expected.to eq(
          title: 'Get users',
          method: :get,
          url: 'http://example.com',
          body: '{"message":"ping"}',
          headers: { 'Content-Type': 'application/json' },
          open_timeout: 10,
          read_timeout: 10,
          sent_at: nil
        )
      end
    end

    describe '.default_driver' do
      context 'driver is undefined in class' do
        subject { described_class.default_driver }

        it { is_expected.to eq LunaPark::Http::Send }
      end

      context 'driver is defined in class' do
        class Driver; end

        let(:request_class) do
          Class.new(described_class) { driver Driver }
        end

        subject { request_class.default_driver }

        it { is_expected.to eq Driver }
      end
    end

    describe '.driver' do
      let(:request_class) { Class.new(described_class) }
      let(:driver_class) { double }

      it 'should set default driver to class' do
        expect { request_class.driver(driver_class) }.to change(request_class, :default_driver)
          .from(LunaPark::Http::Send)
          .to(driver_class)
      end
    end
  end
end
