# frozen_string_literal: true

require 'fakefs/spec_helpers'

module LunaPark
  module CLI
    RSpec.describe Interactors::SinglePattern do
      # For create remove and update fake dir
      include FakeFS::SpecHelpers

      let(:interactor) { described_class.new pattern: :form, type: :single, at: path, opts: opts }
      let(:path)       { Values::Path.new 'name/of/dir/class_name' }
      let(:opts)       { { create_dir: true } }

      let(:template) { object_double(LunaPark::CLI::Entities::Template.new, render: 'foobar') }

      before do
        allow(Entities::Template).to receive(:===).with(template).and_return(true)
      end

      describe '.call' do
        subject(:call) { interactor.call }

        it 'should be success' do
          expect { call }.to change { interactor.success? }.to(true)
        end
      end
    end
  end
end
