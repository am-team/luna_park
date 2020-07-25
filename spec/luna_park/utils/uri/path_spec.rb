# frozen_string_literal: true

require 'ostruct'
require 'luna_park/utils/uri/path'
require 'luna_park/errors'

RSpec.describe LunaPark::Utils::URI::Path do
  subject(:path) { described_class.new(path_string) }

  let(:path_string) { 'api/v1/users' }

  it { is_expected.to be_a String }

  describe '.wrap' do
    subject(:wrap) { described_class.wrap(input) }

    context "when input is a #{described_class}" do
      let(:input) { path }

      it { is_expected.to be_a described_class }
      it { is_expected.to eq path }
    end

    context 'when input is a String' do
      let(:input) { path_string }

      it { is_expected.to be_a described_class }
      it { is_expected.to eq path_string }
    end

    context 'when input is nil' do
      let(:input) { nil }

      it { is_expected.to be nil }
    end

    context 'when input is unknown' do
      let(:input) { OpenStruct.new }

      it { expect { wrap }.to raise_error LunaPark::Errors::Unwrapable }
    end
  end

  describe '#+' do
    subject(:add) { path + input }

    context 'when given non-root string' do
      let(:input) { 'orders' }

      it { is_expected.to eq 'api/v1/users/orders' }
      it { expect { add }.not_to change { path } }
    end
  end

  describe '#<<' do
    subject(:add!) { path << input }

    context 'when given non-root string' do
      let(:input) { 'orders' }

      it { is_expected.to eq 'api/v1/users/orders' }
      it { expect { add! }.to change { path }.from('api/v1/users').to('api/v1/users/orders') }
    end
  end

  describe '#to_root' do
    subject(:to_root) { path.to_root }

    context 'when given non-root string' do
      let(:path_string) { 'api/v1/users' }

      it { is_expected.to eq '/api/v1/users' }
      it { expect { to_root }.not_to change { path } }
    end

    context 'when given root string' do
      let(:path_string) { '/api/v1/users' }

      it { is_expected.to eq path_string }
    end
  end

  describe '#to_root!' do
    subject(:to_root!) { path.to_root! }

    context 'when given non-root string' do
      let(:path_string) { 'api/v1/users' }

      it { is_expected.to eq '/api/v1/users' }
      it { expect { to_root! }.to change { path }.to('/api/v1/users') }
    end

    context 'when given root string' do
      let(:path_string) { '/api/v1/users' }

      it { is_expected.to eq path_string }
    end
  end

  describe '#root?' do
    subject(:root?) { path.root? }

    context 'when given non-root string' do
      let(:path_string) { 'api/v1/users' }

      it { is_expected.to be false }
    end

    context 'when given root string' do
      let(:path_string) { '/api/v1/users' }

      it { is_expected.to be true }
    end
  end

  describe '#dup' do
    subject(:dup) { path.dup }

    it { is_expected.not_to be path }
  end
end
