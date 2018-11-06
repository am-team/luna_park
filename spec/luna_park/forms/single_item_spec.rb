# frozen_string_literal: true

require 'singleton'

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

  class RegisterVisitor < LunaPark::Forms::SingleItem
    validator VisitorValidator

    private
    attr_accessor :name

    def perform
      JournalRepo.instance.save name
    end
  end
end

module LunaPark
  RSpec.describe Forms::SingleItem do

    shared_examples 'performed' do
      it 'performed object is change' do
        expect { subject }.to change { Reception::JournalRepo.instance.count }.by 1
      end
    end

    shared_examples 'not performed' do
      it 'performed object is not change' do
        expect { subject }.not_to change { Reception::JournalRepo.instance.count }
      end
    end

    let(:correct_record)   { { name: 'John Doe' } }
    let(:incorrect_record) { { name: 42 } }

    let(:form) { Reception::RegisterVisitor.new(params) }

    describe '.complete!' do
      subject { form.complete! }

      context 'when fill form with correct record' do
        let(:params) { correct_record }

        it { is_expected.to be true }
        it_behaves_like 'performed'
      end

      context 'when fill form with incorrect record' do
        let(:params) { incorrect_record }

        it { is_expected.to be false }
        it_behaves_like 'not performed'
      end
    end

    describe '.errors!' do
      subject { form.errors }

      context 'when fill form with correct record' do
        let(:params) { correct_record }

        it { is_expected.to be_instance_of Hash }
        it { is_expected.to be_empty }
      end

      context 'when fill form with incorrect record' do
        let(:params) { incorrect_record }

        it { is_expected.to be_instance_of Hash }
        it { is_expected.to_not be_empty }
      end
    end

    describe '.result' do
      subject { form.result }

      context 'before form completed' do
        let(:params) { correct_record }

        it { is_expected.to be_nil}
      end

      context 'after form completed' do
        before { form.complete! }

        context 'when fill form with correct record' do
          let(:params) { correct_record }

          # TODO: should be rewrite it
          it 'should be eq performed object' do
            is_expected.to eq Reception::JournalRepo.instance
          end
        end

        context 'when fill form with incorrect record' do
          let(:params) { incorrect_record }

          it { is_expected.to be_nil}
        end
      end
    end
  end
end
