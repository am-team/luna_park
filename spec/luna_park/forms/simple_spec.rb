# frozen_string_literal: true

require 'singleton'

module FormsSimpleSpec
  module Reception
    class VisitorValidator < LunaPark::Validators::Dry
      validation_schema do
        required(:name).value(type?: String)
      end
    end

    class JournalRepo
      include Singleton

      def initialize
        @records = []
      end

      def save(record)
        records << record
        self
      end

      def count
        records.size
      end

      private

      attr_reader :records
    end

    class RegisterVisitor < LunaPark::Forms::Simple
      validator VisitorValidator

      private

      def perform(valid_params)
        JournalRepo.instance.save valid_params[:name]
      end
    end
  end
end

module LunaPark
  RSpec.describe Forms::Simple do
    let(:repo) { FormsSimpleSpec::Reception::JournalRepo.instance }

    shared_examples 'performed' do
      it 'performed object changes' do
        expect { subject }.to change { repo.count }.by 1
      end
    end

    shared_examples 'not performed' do
      it 'performed object not changed' do
        expect { subject }.not_to change { repo.count }
      end
    end

    let(:correct_record)   { { name: 'John Doe' } }
    let(:incorrect_record) { { name: 42 } }
    let(:klass) { FormsSimpleSpec::Reception::RegisterVisitor }

    let(:form) { klass.new(params) }

    describe '.submit' do
      subject { form.submit }

      context 'when fill form with correct record,' do
        let(:params) { correct_record }

        it { is_expected.to be true }
        it_behaves_like 'performed'
      end

      context 'when fill form with incorrect record,' do
        let(:params) { incorrect_record }

        it { is_expected.to be false }
        it_behaves_like 'not performed'
      end

      context 'when perform method undefined,' do
        let(:defected_klass) { klass.dup }
        let(:form) { defected_klass.new correct_record }
        before { defected_klass.remove_method :perform }

        it 'raises AbstractMethod error,' do
          expect { subject }.to raise_error Errors::AbstractMethod
        end
      end
    end

    describe '.errors' do
      subject { form.errors }

      context 'when fill form with correct record,' do
        let(:params) { correct_record }

        it { is_expected.to be_instance_of Hash }
        it { is_expected.to be_empty }
      end

      context 'when fill form with incorrect record,' do
        let(:params) { incorrect_record }

        it { is_expected.to be_instance_of Hash }
        it { is_expected.to_not be_empty }
      end
    end

    describe '.result' do
      subject { form.result }

      context 'before form submited,' do
        let(:params) { correct_record }

        it { is_expected.to be_nil }
      end

      context 'after form submited,' do
        before { form.submit }

        context 'when fill form with correct record,' do
          let(:params) { correct_record }

          it 'returns performed object' do
            is_expected.to eq repo
          end
        end

        context 'when fill form with incorrect record,' do
          let(:params) { incorrect_record }

          it { is_expected.to be_nil }
        end
      end
    end
  end
end
