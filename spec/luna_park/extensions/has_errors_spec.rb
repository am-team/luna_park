# frozen_string_literal: true

require 'luna_park/extensions/has_errors'

class CustomErrorBase < LunaPark::Errors::Business
  notify :debug
  message 'Default message', i18n_key: 'errors.default_key'
end

class Service
  include LunaPark::Extensions::HasErrors

  business_error :business_error
  system_error :system_error
  custom_error :custom_error, CustomErrorBase
end

module LunaPark
  RSpec.describe LunaPark::Extensions::HasErrors do
    describe '.business_error' do
      it 'should define business error' do
        expect(Service::BusinessError < Errors::Business).to eq true
      end

      context 'with params' do
        before do
          Service.business_error(:business_error_example, 'Business error', i18n_key: 'errors.business_error', notify: :info)
        end

        subject(:business_error) { Service::BusinessErrorExample }

        it 'assigns params to the error' do
          expect(business_error.default_message_block.call({})).to eq 'Business error'
          expect(business_error.i18n_key).to eq 'errors.business_error'
          expect(business_error.default_notify).to eq :info
        end
      end
    end

    describe '#business_error' do
      let(:service) { Service.new }

      it { expect { service.error :business_error }.to raise_error(Service::BusinessError) }

      context 'when set business error params' do
        it 'should raise error with all params' do
          expect do
            service.error(:business_error, 'Error message', detail: :foo, notify: :debug)
          end.to raise_error(
            an_instance_of(Service::BusinessError)
              .and(having_attributes(message: 'Error message', details: { detail: :foo }, notify_lvl: :debug))
          )
        end
      end
    end

    describe '.system_error' do
      it 'should define system error' do
        expect(Service::SystemError < Errors::System).to eq true
      end

      context 'with params' do
        before do
          Service.business_error(:system_error_example, 'System error', i18n_key: 'errors.system_error', notify: :info)
        end

        subject(:system_error) { Service::SystemErrorExample }

        it 'assigns params to the error' do
          expect(system_error.default_message_block.call({})).to eq 'System error'
          expect(system_error.i18n_key).to eq 'errors.system_error'
          expect(system_error.default_notify).to eq :info
        end
      end
    end

    describe '#system_error' do
      let(:service) { Service.new }

      it { expect { service.error :system_error }.to raise_error(Service::SystemError) }

      context 'when set system error params' do
        it 'should raise error with all params' do
          expect do
            service.error(:system_error, 'Error message', detail: :foo, notify: :debug)
          end.to raise_error(
            an_instance_of(Service::SystemError)
              .and(having_attributes(message: 'Error message', details: { detail: :foo }, notify_lvl: :debug))
          )
        end
      end
    end

    describe '.custom_error' do
      it 'should define custom error' do
        expect(Service::CustomError < CustomErrorBase).to eq true
      end

      context 'with params' do
        before do
          Service.custom_error(:custom_error_example, CustomErrorBase, 'Custom error', i18n_key: 'errors.custom_error', notify: :info)
        end

        subject(:custom_error) { Service::CustomErrorExample }

        it 'assigns params to the error' do
          expect(custom_error.default_message_block.call({})).to eq 'Custom error'
          expect(custom_error.i18n_key).to eq 'errors.custom_error'
          expect(custom_error.default_notify).to eq :info
        end
      end

      context 'without params' do
        before do
          Service.custom_error(:custom_error_example, CustomErrorBase)
        end

        subject(:custom_error) { Service::CustomError }

        it 'inherits params from the base error' do
          expect(custom_error.default_message_block.call({})).to eq 'Default message'
          expect(custom_error.i18n_key).to eq 'errors.default_key'
          expect(custom_error.default_notify).to eq :debug
        end
      end

      context 'when inherit_from is not a superclass of Errors::Base' do
        it 'raises error' do
          expect { Service.custom_error(:custom_error_example, RuntimeError) }.to raise_error(ArgumentError)
        end
      end
    end

    describe '.error_class_name' do
      context 'when camel case' do
        subject(:class_name) { Service.error_class_name 'CamelCase' }

        it { is_expected.to eq('CamelCase') }
      end

      context 'when snake case' do
        subject(:class_name) { Service.error_class_name :snake_case }

        it { is_expected.to eq('SnakeCase') }
      end

      context 'when unknown type case' do
        it { expect { Service.error_class_name(nil) }.to raise_error(ArgumentError) }
      end
    end
  end
end
