# frozen_string_literal: true

module LunaPark
  module CLI
    RSpec.describe Entities::Template do
      let(:template) do
        described_class.new(
          pattern: :form,
          type: :single,
          class_name: 'ClassName',
          namespaces: %w[Foo Bar],
          opts: OpenStruct.new(foo: 'bar')
        )
      end

      describe '#file_path' do
        subject { template.file_path }

        it { is_expected.to be_an_instance_of Pathname }

        it 'should be eq path of template file' do
          is_expected.to eq(Gem.lib + 'luna_park/cli/templates/patterns/forms/single.rb.erb')
        end
      end

      describe '#file' do
        subject { template.file }

        it { is_expected.to be_an_instance_of String }

        it 'should be eq content of template file' do
          is_expected.to eq File.read(Gem.lib + 'luna_park/cli/templates/patterns/forms/single.rb.erb')
        end
      end

      describe '#render' do
        subject { template.render }

        let(:output) do
          <<~DATA
            module Foo
              module Bar
                class ClassName < LunaPark::SomePattern
                  def foo
                    'bar'
                  end
                end
              end
            end
          DATA
        end

        before do
          allow(template).to receive(:file) do
            <<~TPL
              class <%=class_name%> < LunaPark::SomePattern
                def foo
                  '<%= opts.foo %>'
                end
              end
            TPL
          end
        end

        it { is_expected.to be_an_instance_of String }

        it 'render the template data' do
          is_expected.to eq output
        end
      end
    end
  end
end
