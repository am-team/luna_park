# frozen_string_literal: true

require 'fakefs/spec_helpers'

module LunaPark
  RSpec.describe CLI::Values::Path do
    let(:path) { described_class.new 'name/of/dir/class_name' }

    describe '#dir' do
      subject { path.dir }

      it { is_expected.to be_an_instance_of Pathname }
      it { is_expected.to eq Pathname.new('name/of/dir') }
    end

    describe '#class_name' do
      subject { path.class_name }

      it { is_expected.to be_an_instance_of String }
      it { is_expected.to eq 'ClassName' }
    end

    describe '#namespaces' do
      subject { path.namespaces }

      it { is_expected.to be_an_instance_of Array }
      it 'should be consist all namespaces' do
        is_expected.to eq %w[Name Of Dir]
      end
    end
  end
end
