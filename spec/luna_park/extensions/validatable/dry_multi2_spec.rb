# frozen_string_literal: true

require 'luna_park/extensions/validatable'
require 'luna_park/extensions/validatable/dry'

module ExtensionsValidatableDryMulti2Spec
  class HumanTypeValidator < LunaPark::Validators::Dry
    validation_schema do
      params do
        required(:type).value(eql?: 'human')
      end
    end
  end

  class NameValidator < LunaPark::Validators::Dry
    validation_schema do
      params do
        required(:name) { filled? & str? }
      end
    end
  end

  class MyMultiForm
    include LunaPark::Extensions::Validatable::Dry

    validator :body do
      params do
        required(:foo) { filled? & str? & eql?('Foo') }
      end
    end

    def initialize(params)
      @params = params
    end

    # valid_params is a private method, given by mixin Validatable, but we need to test it
    def _valid_params
      valid_params # method private cause needed only for internal usage
    end

    private

    attr_reader :params # define abstract method
  end

  class MyMultiForm2 < MyMultiForm
    validator :uri, :query, HumanTypeValidator + NameValidator
  end
end

module LunaPark
  RSpec.describe Extensions::Validatable::Dry do
    subject(:form) { form_class.new(params) }

    let(:form_class) { ExtensionsValidatableDryMulti2Spec::MyMultiForm2 }

    context 'when invalid params given,' do
      let(:params) { { body: { 'foo' => 'Foo' } } }

      it { is_expected.not_to be_valid }

      describe '#validation_errors_array' do
        subject(:validation_errors_array) { form.validation_errors_array }

        it 'contains expected errors' do
          is_expected.to eq [input: {}, path: [:type], source: %i[uri query], text: 'is missing']
        end
      end

      describe '#validation_error_arrays' do
        subject(:error_arrays) { form.validation_error_arrays }

        it 'contains expected errors' do
          is_expected.to eq uri: { query: [input: {}, path: [:type], source: %i[uri query], text: 'is missing'] }
        end
      end

      describe '#validation_errors_tree' do
        subject(:validation_errors_tree_nested) { form.validation_errors_tree }

        it 'contains expected errors' do
          is_expected.to eq uri: { query: { type: ['is missing'] } }
        end
      end

      describe '#valid_params' do
        subject(:valid_params) { form._valid_params }

        it { is_expected.to be_empty }
      end
    end

    context 'when valid params given,' do
      let(:params) { { body: { 'foo' => 'Foo' }, uri: { query: { 'type' => 'human', 'name' => 'John' } } } }

      it { is_expected.to be_valid }

      describe '#validation_errors_array' do
        subject(:validation_errors_array) { form.validation_errors_array }

        it { is_expected.to be_empty }
      end

      describe '#validation_error_arrays' do
        subject(:error_arrays) { form.validation_error_arrays }

        it { is_expected.to be_empty }
      end

      describe '#validation_errors_tree' do
        subject(:validation_errors_tree) { form.validation_errors_tree }

        it { is_expected.to be_empty }
      end

      describe '#valid_params' do
        subject(:valid_params) { form._valid_params }

        it 'contains output params' do
          is_expected.to eq body: { foo: 'Foo' }, uri: { query: { type: 'human', name: 'John' } }
        end
      end
    end
  end
end
