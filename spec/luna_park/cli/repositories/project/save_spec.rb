# frozen_string_literal: true

require 'fakefs/spec_helpers'

module LunaPark
  module CLI
    RSpec.describe Repositories::Project::Save do
      # For create remove and update fake dir
      include FakeFS::SpecHelpers

      let(:save)     { described_class.new template, at: path }
      let(:path)     { Values::Path.new 'name/of/dir/class_name' }
      let(:template) { object_double(LunaPark::CLI::Entities::Template.new, render: 'foobar') }

      before do
        allow(Entities::Template).to receive(:===).with(template).and_return(true)
      end

      describe '#call!' do
        subject(:call!) { save.call! }

        context 'dir already created' do
          before { FileUtils.mkdir_p'name/of/dir' }

          it { is_expected.to be_truthy }

          it 'should create file' do
            expect { call! }.to change { File.exist?('name/of/dir/class_name.rb') }.from(false).to(true)
          end

          it 'should create file with expected content' do
            call!
            expect(File.read('name/of/dir/class_name.rb')).to eq 'foobar'
          end
        end

        context 'dir does not exists' do
          before { FileUtils.rm 'name/of/dir' if Dir.exist? 'name/of/dir' }

          it { expect { call! }.to raise_error(Errors::CouldNotSaveFile) }
        end
      end
    end
  end
end
