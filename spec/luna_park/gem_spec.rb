# frozen_string_literal: true

module LunaPark
  RSpec.describe Gem do
    describe '.spec' do
      subject(:spec) { described_class.spec }

      it { is_expected.to be_an_instance_of ::Gem::Specification }
    end

    describe '.root' do
      subject(:root) { described_class.root }

      # get paren of spec dir
      let(:current_dir) { Pathname.new(File.dirname(__dir__)).parent }

      it { is_expected.to be_an_instance_of Pathname }
      it { is_expected.to eq current_dir }
    end

    describe '.lib' do
      subject(:lib) { described_class.lib }

      # get paren of spec dir

      it { is_expected.to be_an_instance_of Pathname }
      it { is_expected.to eq described_class.root + 'lib' }
    end

    describe '.title' do
      subject(:title) { described_class.title }

      # get paren of spec dir

      it { is_expected.to be_an_instance_of String }
      it { is_expected.to eq 'luna_park' }
    end

    describe '.version' do
      subject(:version) { described_class.version }

      # get paren of spec dir

      it { is_expected.to be_an_instance_of String }
      it { is_expected.to eq LunaPark::VERSION }
    end
  end
end
