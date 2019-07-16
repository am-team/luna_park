# frozen_string_literal: true

require_relative '../../../lib/luna_park/extensions/validatable'

module ExtensionsValidatableSpec
  class MyValidator
    def self.validate(params)
      new(params)
    end

    def initialize(params)
      @params = params
    end

    def errors_tree
      @errors_tree ||= {}.tap do |errors|
        errors[:foo] ||= 'is missing' unless @params.key?(:foo) || @params.key?('foo')
        errors[:bar] ||= 'is missing' unless @params.key?(:bar) || @params.key?('bar')
      end
    end

    alias errors errors_tree

    def success?
      errors.empty?
    end

    def valid_params
      @valid_params ||= success? ? @params.transform_keys(&:to_sym) : {}
    end
  end

  class MyForm
    include LunaPark::Extensions::Validatable

    validator MyValidator # must respond_to #errors, #success?, #valid_params, .validate

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
end

module LunaPark
  RSpec.describe Extensions::Validatable do
    subject(:form) { form_class.new(params) }

    let(:form_class) { ExtensionsValidatableSpec::MyForm }

    describe '.validator' do
      subject(:validator) { form_class.validator }

      it { is_expected.to be ExtensionsValidatableSpec::MyValidator }
    end

    context 'when invalid params given,' do
      let(:params) { { 'foo' => 'Foo' } }

      it { is_expected.not_to be_valid }

      describe '#validation_errors' do
        subject(:validation_errors) { form.validation_errors }

        it 'contains expected errors' do
          is_expected.to eq bar: 'is missing'
        end
      end

      describe '#valid_params' do
        subject(:valid_params) { form._valid_params }

        it { is_expected.to be_empty }
      end
    end

    context 'when valid params given,' do
      let(:params) { { 'foo' => 'Foo', 'bar' => 'Bar' } }

      it { is_expected.to be_valid }

      describe '#validation_errors' do
        subject(:validation_errors) { form.validation_errors }

        it { is_expected.to be_empty }
      end

      describe '#valid_params' do
        subject(:valid_params) { form._valid_params }

        it 'contains output params' do
          is_expected.to eq foo: 'Foo', bar: 'Bar'
        end
      end
    end
  end
end
