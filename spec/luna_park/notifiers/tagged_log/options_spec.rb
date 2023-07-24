# frozen_string_literal: true

require 'luna_park/notifiers/tagged_log/options'

module LunaPark
  module Notifiers
    module TaggedLog
      RSpec.describe Options do
        let(:config) { described_class.wrap(options) }
        let(:options) do
          {
            default_tag: 'shoryuken',
            app: 'spcoupons',
            app_env: 'production',
            instance: 'prod',
            min_lvl: :debug
          }
        end

        describe '#wrap' do
          context 'when success' do
            it do
              expect(config).to have_attributes(options)
            end
          end

          context 'when options empty' do
            let(:config) { described_class.new }

            it do
              expect { config }.to raise_error(ArgumentError), 'TaggedLog not properly configured'
            end
          end

          context 'when options empty hash' do
            let(:options) { {} }

            it do
              expect { config }.to raise_error(ArgumentError), 'TaggedLog not properly configured'
            end
          end

          context 'default_tag' do
            context 'when omit' do
              let(:options) do
                {
                  app: 'spcoupons',
                  app_env: 'production',
                  instance: 'prod',
                  min_lvl: :debug
                }
              end

              it do
                expect { config }.to raise_error(ArgumentError), 'TaggedLog not properly configured'
              end
            end

            context 'when empty' do
              let(:options) do
                {
                  default_tag: '',
                  app: 'spcoupons',
                  app_env: 'production',
                  instance: 'prod',
                  min_lvl: :debug
                }
              end

              it do
                expect { config }.to raise_error(ArgumentError), 'TaggedLog not properly configured'
              end
            end

            context 'when bad type' do
              let(:options) do
                {
                  default_tag: [:ddd],
                  app: 'spcoupons',
                  app_env: 'production',
                  instance: 'prod',
                  min_lvl: :debug
                }
              end

              it do
                expect { config }.to raise_error(ArgumentError), 'TaggedLog not properly configured'
              end
            end
          end
        end
      end
    end
  end
end
