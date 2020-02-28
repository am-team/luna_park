# frozen_string_literal: true

require 'ostruct'
require 'luna_park/utils/uri/query'
require 'luna_park/errors'

RSpec.describe LunaPark::Utils::URI::Query do
  subject(:query) { described_class.new(query_string) }

  let(:query_string) { 'foo=bar&baz=42' }

  it { is_expected.to be_a String }

  describe '.wrap' do
    subject(:wrap) { described_class.wrap(input) }

    context 'when input is a String' do
      let(:input) { query_string }

      it { is_expected.to be_a described_class }
      it { is_expected.to be_a String }
      it { is_expected.to eq query_string }
    end

    context 'when input is a Hash' do
      let(:input) { { foo: :bar, baz: 42 } }

      it { is_expected.to be_a described_class }
      it { is_expected.to be_a String }
      it { is_expected.to eq query_string }
    end

    context 'when input is an Array' do
      let(:input) { [%i[foo bar], [:baz, 42]] }

      it { is_expected.to be_a described_class }
      it { is_expected.to be_a String }
      it { is_expected.to eq query_string }
    end

    context 'when input is unknown' do
      let(:input) { OpenStruct.new }

      it { expect { wrap }.to raise_error LunaPark::Errors::Unwrapable }
    end
  end

  describe '#[]' do
    subject(:get) { query['baz'] }

    it { is_expected.to eq '42' }
  end

  describe '#==' do
    subject(:eql) { query.eql(other) }

    context "when other is a #{described_class}" do
      it { expect(query == described_class.new('foo=bar&baz=42')).to be true }
      it { expect(query == described_class.new('foo=bar&baz=44')).to be false }
    end

    context 'when other is a String' do
      it { expect(query == 'foo=bar&baz=42').to be true }
      it { expect(query == 'foo=bar&baz=44').to be false }
    end

    context 'when other is a Hash' do
      it { expect(query == { 'foo' => 'bar', 'baz' => '42' }).to be true }
      it { expect(query == { 'foo' => 'bar', 'baz' => '44' }).to be false }
    end

    context 'when other is an Array' do
      it { expect(query == [%w[foo bar], %w[baz 42]]).to be true }
      it { expect(query == [%w[foo bar], %w[baz 44]]).to be false }
    end

    context 'when other is unknown' do
      it { expect(query == double(to_s: 'foo=bar&baz=42')).to be true }
      it { expect(query == double(to_s: 'foo=bar&baz=44')).to be false }
    end
  end

  describe '#to_h' do
    subject(:to_h) { query.to_h }

    it { is_expected.to eq('foo' => 'bar', 'baz' => '42') }
  end

  describe '#to_a' do
    subject(:to_a) { query.to_a }

    it { is_expected.to eq [%w[foo bar], %w[baz 42]] }
  end

  describe '#to_s' do
    subject(:to_s) { query.to_s }

    it { is_expected.to eq query_string }
  end
end
