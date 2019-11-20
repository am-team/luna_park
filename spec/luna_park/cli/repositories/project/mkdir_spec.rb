# frozen_string_literal: true

require 'fakefs/spec_helpers'

module LunaPark
  module CLI
    RSpec.describe Repositories::Project::Mkdir do
      # For create remove and update fake dir
      include FakeFS::SpecHelpers

      let(:mkdir) { described_class.new path, opts }
      let(:path)  { Values::Path.new 'name/of/dir/class_name' }
      let(:opts)  { {} }

      describe '#call!' do
        subject(:call!) { mkdir.call! }

        context 'dir already created' do
          before { FileUtils.mkdir_p 'name/of/dir' }

          it { is_expected.to be_truthy }
        end

        context 'create_dir enabled' do
          let(:opts) { { create_dir: true } }

          it 'create directory' do
            expect { call! }.to change { Dir.exist?('name/of/dir') }.from(false).to(true)
          end

          it { is_expected.to be_truthy }
        end

        context 'create_dir disabled' do
          let(:opts) { { create_dir: false } }

          it 'does not create directory' do
            expect { call! }.to raise_error Errors::CouldNotCreateDir
          end
        end
      end
    end
  end
end
