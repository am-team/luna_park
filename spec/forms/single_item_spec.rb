# frozen_string_literal: true

RSpec.describe LunaPark::Forms::SingleItem do
  class Form < described_class; end

  let(:form_class) { Form }
  let(:form) { form_class.new }

  context 'before complete' do
    describe '.result' do
      subject(:result) { form.result }

      it { is_expected.to be_nil }
    end

    describe '.errors' do
      subject(:errors) { form.errors }

      it { is_expected.to be eq({}) }
    end
  end
end
