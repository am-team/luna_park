# frozen_string_literal: true

require 'luna_park/utils/uri'

RSpec.describe LunaPark::Utils::URI do
  subject(:uri) { described_class.new(input_uri_str, **input_uri_hash) }

  let(:input_uri_str)  { '/users' }
  let(:input_uri_hash) { { scheme: 'http', host: 'example.com', query: { foo: 42 }, fragment: '6' } }

  describe '.wrap' do
    subject(:wrap) { described_class.wrap(input) }

    context "when given #{described_class}" do
      let(:input) { uri }

      it 'returns input' do
        is_expected.to be input
      end
    end

    context 'when given String' do
      let(:input) { '/users' }

      it { is_expected.to be_a described_class }
      it { is_expected.to eq(path: '/users') }
      it { is_expected.to eq '/users' }
    end

    context 'when given Hash' do
      let(:input) { { scheme: 'http', host: 'example.com', path: '/users' } }

      it { is_expected.to be_a described_class }
      it { is_expected.to eq 'http://example.com/users' }
    end

    context 'when given unknown' do
      let(:input) { double }

      it { expect { wrap }.to raise_error LunaPark::Errors::Unwrapable }
    end
  end

  describe '#new' do
    subject(:new) { uri.new(attrs) }

    let(:attrs) { { scheme: 'https', query: { bar: 'baz' } } }

    it { is_expected.to be_a described_class }
    it { is_expected.to eq 'https://example.com/users?bar=baz#6' }
  end

  describe '#query' do
    subject(:query) { uri.query }

    it { is_expected.to be_a LunaPark::Utils::URI::Query }
    it { is_expected.to eq 'foo=42' }
  end

  describe '#query=' do
    it 'changes query component' do
      expect { uri.query = [%w[foo 44], %w[bar baz]] }.to change { uri.to_s }
        .from('http://example.com/users?foo=42#6')
        .to('http://example.com/users?foo=44&bar=baz#6')
    end
  end

  describe '#==' do
    context "when other is a #{described_class}" do
      it { expect(uri == uri.dup).to be true }
      it { expect(uri == described_class.new('foo')).to be false }
    end

    context 'when other is a String' do
      it { expect(uri == 'http://example.com/users?foo=42#6').to be true }
      it { expect(uri == 'http://example.com/users').to          be false }
    end

    context 'when other is a Hash' do
      it { expect(uri == { scheme: 'http', host: 'example.com', path: '/users', query: 'foo=42', fragment: '6' }).to be true }
      it { expect(uri == { scheme: 'http', host: 'example.com', path: '/users' }).to be false }
    end
  end

  describe '#to_h' do
    subject(:to_h) { uri.to_h }

    it { is_expected.to eq(scheme: 'http', host: 'example.com', path: '/users', query: 'foo=42', fragment: '6') }
  end

  describe '#to_s' do
    subject(:to_s) { uri.to_s }

    it { is_expected.to eq 'http://example.com/users?foo=42#6' }
  end

  describe '#to_str' do
    subject(:to_str) { uri.to_str }

    it { is_expected.to eq uri.to_s }
  end

  describe '#to_uri' do
    subject(:to_uri) { uri.to_uri }

    it { is_expected.to be_a URI::Generic }
    it { expect(to_uri.to_s).to eq URI('http://example.com/users?foo=42#6').to_s }
  end
end
