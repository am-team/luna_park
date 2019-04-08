# frozen_string_literal: true

RSpec.describe LunaPark::Validators::Dry do
  let(:human_validator) do
    Class.new(described_class) do
      validation_schema do
        required(:type).value(eql?: 'human')
      end
    end
  end

  let(:validator_class) { human_validator }
  let(:validator)       { validator_class.new(params) }
  let(:valid_params)    { { type: 'human' } }
  let(:invalid_params)  { { type: 'robot' } }

  describe '#success?' do
    subject { validator.success? }

    context 'when sent valid params' do
      let(:params) { valid_params }

      it { is_expected.to be true }
    end

    context 'when sent invalid params' do
      let(:params) { invalid_params }

      it { is_expected.to be false }
    end
  end

  describe '#valid_params' do
    subject { validator.valid_params }

    context 'when sent valid params' do
      let(:params) { valid_params }

      it { is_expected.to be_a Hash }

      it 'should be eq sent params' do
        is_expected.to eq valid_params
      end
    end

    context 'when sent invalid params' do
      let(:params) { invalid_params }

      it { is_expected.to be_a Hash }
      it { is_expected.to be_empty }
    end

    context 'when sent params include unspecified values' do
      let(:unspecified) { { name: 'John Doe' } }
      let(:params) { valid_params.merge unspecified }

      it 'should not be included' do
        is_expected.to_not include unspecified
      end
    end
  end

  describe '#errors' do
    subject { validator.errors }

    context 'when sent valid params' do
      let(:params) { valid_params }

      it { is_expected.to be_a Hash }
      it { is_expected.to be_empty }
    end

    context 'when sent invalid params' do
      let(:params) { invalid_params }

      it { is_expected.to be_a Hash }
      it { is_expected.to_not be_empty }
    end
  end

  describe '.validate' do
    subject { validator_class.validate(valid_params) }

    it 'should be an instance of validation class' do
      is_expected.to be_instance_of validator_class
    end
  end
end
