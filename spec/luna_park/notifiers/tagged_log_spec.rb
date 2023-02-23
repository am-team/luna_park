# frozen_string_literal: true

require 'luna_park/notifiers/tagged_log'
require 'timecop'

module LunaPark
  module Notifiers
    RSpec.describe TaggedLog do
      let(:logger) { described_class.new(options) }
      let(:options) do
        {
          default_tag: 'shoryuken',
          app: 'spcoupons',
          app_env: 'production',
          instance: 'prod',
          min_lvl: :debug
        }
      end
      let(:message) { 'test message' }

      describe '#post' do
        before { Timecop.freeze }
        after { Timecop.return }
        let(:timestamp) { Time.now.iso8601(3) }

        context 'when without tags' do
          subject(:post) { logger.info(message) }
          let(:expected_log) do
            <<~MULTILINE.chomp
              {"tags":"shoryuken","app":"spcoupons","app_env":"production","instance":"prod","created_at":"#{timestamp}","ok":true,"details":{"message":"#{message}"}}\n
            MULTILINE
          end

          it do
            expect { post }.to output(expected_log).to_stdout
          end
        end

        context 'when with tags | tagged without block' do
          let(:expected_log) do
            <<~MULTILINE
              {"tags":"shoryuken","app":"spcoupons","app_env":"production","instance":"prod","created_at":"#{timestamp}","ok":true,"details":{"message":"#{message}"}}
              {"tags":"shoryuken xxx_receiver method_x","app":"spcoupons","app_env":"production","instance":"prod","created_at":"#{timestamp}","ok":true,"details":{"message":"#{message}"}}
              {"tags":"shoryuken","app":"spcoupons","app_env":"production","instance":"prod","created_at":"#{timestamp}","ok":true,"details":{"message":"#{message}"}}
              {"tags":"shoryuken xxx_receiver","app":"spcoupons","app_env":"production","instance":"prod","created_at":"#{timestamp}","ok":true,"details":{"message":"#{message}"}}
              {"tags":"shoryuken xxx_receiver method_x","app":"spcoupons","app_env":"production","instance":"prod","created_at":"#{timestamp}","ok":true,"details":{"message":"#{message}"}}
              {"tags":"shoryuken xxx_receiver method_y","app":"spcoupons","app_env":"production","instance":"prod","created_at":"#{timestamp}","ok":true,"details":{"message":"#{message}"}}
              {"tags":"shoryuken xxx_receiver","app":"spcoupons","app_env":"production","instance":"prod","created_at":"#{timestamp}","ok":true,"details":{"message":"#{message}"}}
              {"tags":"shoryuken","app":"spcoupons","app_env":"production","instance":"prod","created_at":"#{timestamp}","ok":true,"details":{"message":"#{message}"}}
            MULTILINE
          end

          def log
            logger.info(message)
            logger.tagged('xxx_receiver', 'method_x').info(message)
            logger.info(message)
            logger.push_tags('xxx_receiver')
            logger.info(message)
            logger.tagged('method_x').info(message)
            logger.tagged('method_y').info(message)
            logger.info(message)
            logger.clear_tags!
            logger.info(message)
          end

          it do
            expect { log }.to output(expected_log).to_stdout
          end
        end

        context 'when with tags | tagged with block' do
          let(:expected_log) do
            <<~MULTILINE
              {"tags":"shoryuken","app":"spcoupons","app_env":"production","instance":"prod","created_at":"#{timestamp}","ok":true,"details":{"message":"#{message}"}}
              {"tags":"shoryuken xxx_receiver method_x","app":"spcoupons","app_env":"production","instance":"prod","created_at":"#{timestamp}","ok":true,"details":{"message":"#{message}"}}
              {"tags":"shoryuken","app":"spcoupons","app_env":"production","instance":"prod","created_at":"#{timestamp}","ok":true,"details":{"message":"#{message}"}}
              {"tags":"shoryuken xxx_receiver","app":"spcoupons","app_env":"production","instance":"prod","created_at":"#{timestamp}","ok":true,"details":{"message":"#{message}"}}
              {"tags":"shoryuken xxx_receiver method_x","app":"spcoupons","app_env":"production","instance":"prod","created_at":"#{timestamp}","ok":true,"details":{"message":"#{message}"}}
              {"tags":"shoryuken xxx_receiver method_y","app":"spcoupons","app_env":"production","instance":"prod","created_at":"#{timestamp}","ok":true,"details":{"message":"#{message}"}}
              {"tags":"shoryuken xxx_receiver","app":"spcoupons","app_env":"production","instance":"prod","created_at":"#{timestamp}","ok":true,"details":{"message":"#{message}"}}
              {"tags":"shoryuken","app":"spcoupons","app_env":"production","instance":"prod","created_at":"#{timestamp}","ok":true,"details":{"message":"#{message}"}}
            MULTILINE
          end

          def log
            logger.info(message)
            logger.tagged('xxx_receiver', 'method_x') { |l| l.info(message) }
            logger.info(message)
            logger.push_tags('xxx_receiver')
            logger.info(message)
            logger.tagged('method_x') { |l| l.info(message) }
            logger.tagged('method_y') { |l| l.info(message) }
            logger.info(message)
            logger.clear_tags!
            logger.info(message)
          end

          it do
            expect { log }.to output(expected_log).to_stdout
          end
        end

        context 'when with tags | tagged with block | deep block' do
          let(:expected_log) do
            <<~MULTILINE
              {"tags":"shoryuken","app":"spcoupons","app_env":"production","instance":"prod","created_at":"#{timestamp}","ok":true,"details":{"message":"#{message}"}}
              {"tags":"shoryuken xxx_receiver method_x","app":"spcoupons","app_env":"production","instance":"prod","created_at":"#{timestamp}","ok":true,"details":{"message":"#{message}"}}
              {"tags":"shoryuken xxx_receiver method_x xxx","app":"spcoupons","app_env":"production","instance":"prod","created_at":"#{timestamp}","ok":true,"details":{"message":"#{message}"}}
              {"tags":"shoryuken xxx_receiver method_x","app":"spcoupons","app_env":"production","instance":"prod","created_at":"#{timestamp}","ok":true,"details":{"message":"#{message}"}}
              {"tags":"shoryuken","app":"spcoupons","app_env":"production","instance":"prod","created_at":"#{timestamp}","ok":true,"details":{"message":"#{message}"}}
            MULTILINE
          end

          def log
            logger.info(message)
            logger.tagged('xxx_receiver', 'method_x') do |l|
              l.info(message)
              l.tagged('xxx') { |log| log.info(message) }
              l.info(message)
            end
            logger.info(message)
          end

          it do
            expect { log }.to output(expected_log).to_stdout
          end
        end
      end
    end
  end
end
