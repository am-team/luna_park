# frozen_string_literal: true

require 'luna_park/notifiers/tagged_log/tagged_formatter'
require 'luna_park/notifiers/tagged_log/options'
require 'luna_park/errors/business'
require 'timecop'

module LunaPark
  RSpec.describe Notifiers::TaggedLog::TaggedFormatter do
    let(:formatter) do
      formatter = described_class.new
      formatter.config = config
      formatter
    end
    let(:config) do
      LunaPark::Notifiers::TaggedLog::Options.wrap(
        default_tag: 'shoryuken',
        app: 'spcoupons',
        app_env: 'production',
        instance: 'prod',
        min_lvl: :debug
      )
    end
    subject(:call) { formatter.call(severity, timestamp, 'program', msg, tags) }
    let(:severity) { :info }
    let(:timestamp) { Time.now }
    let(:msg) do
      {
        original_msg: original_msg,
        details: details
      }
    end
    let(:tags) { ['xxx_receiver'] }
    let(:original_msg) { 'Task is finished' }
    let(:details) { { duration: 0.67, user: { uid: 'uid', name: 'John' } } }

    before { Timecop.freeze }
    after { Timecop.return }

    describe '#call' do
      context 'text message without details without tags' do
        subject(:call) { formatter.call(severity, timestamp, 'program', msg) }
        let(:msg) do
          {
            original_msg: 'test message',
            details: {}
          }
        end

        let(:expected_message) do
          <<~JSON_OUTPUT.chomp
            {"tags":"shoryuken","app":"#{config.app}","app_env":"#{config.app_env}","instance":"#{config.instance}","created_at":"#{timestamp.iso8601(3)}","ok":true,"details":{"message":"test message"}}\n
          JSON_OUTPUT
        end

        it do
          expect(call).to eq expected_message
        end
      end

      context 'text message without details with tags' do
        let(:msg) do
          {
            original_msg: 'test message',
            details: {}
          }
        end

        let(:expected_message) do
          <<~JSON_OUTPUT.chomp
            {"tags":"shoryuken xxx_receiver","app":"#{config.app}","app_env":"#{config.app_env}","instance":"#{config.instance}","created_at":"#{timestamp.iso8601(3)}","ok":true,"details":{"message":"test message"}}\n
          JSON_OUTPUT
        end

        it do
          expect(call).to eq expected_message
        end
      end

      context 'text message with details' do
        let(:expected_message) do
          <<~JSON_OUTPUT.chomp
            {"tags":"shoryuken xxx_receiver","app":"#{config.app}","app_env":"#{config.app_env}","instance":"#{config.instance}","created_at":"#{timestamp.iso8601(3)}","ok":true,"details":{"message":"Task is finished","duration":0.67,"user":{"uid":"uid","name":"John"}}}\n
          JSON_OUTPUT
        end

        it do
          expect(call).to eq expected_message
        end
      end

      context 'hash message without details' do
        let(:msg) do
          {
            original_msg: { user: { id: 111, name: 'XXX' }, sum: 10 },
            details: {}
          }
        end

        let(:expected_message) do
          <<~JSON_OUTPUT.chomp
            {"tags":"shoryuken xxx_receiver","app":"#{config.app}","app_env":"#{config.app_env}","instance":"#{config.instance}","created_at":"#{timestamp.iso8601(3)}","ok":true,"details":{"user":{"id":111,"name":"XXX"},"sum":10}}\n
          JSON_OUTPUT
        end

        it do
          expect(call).to eq expected_message
        end
      end

      context 'hash message with details' do
        let(:msg) do
          {
            original_msg: { user: { id: 111, name: 'XXX' }, sum: 10 },
            details: { user: { surname: 'YYY' }, balance: 100 }
          }
        end

        let(:expected_message) do
          <<~JSON_OUTPUT.chomp
            {"tags":"shoryuken xxx_receiver","app":"#{config.app}","app_env":"#{config.app_env}","instance":"#{config.instance}","created_at":"#{timestamp.iso8601(3)}","ok":true,"details":{"user":{"id":111,"name":"XXX","surname":"YYY"},"sum":10,"balance":100}}\n
          JSON_OUTPUT
        end

        it do
          expect(call).to eq expected_message
        end
      end

      context 'hash message with details with details :)' do
        let(:msg) do
          {
            original_msg: { user: { id: 111, name: 'XXX' }, sum: 10, details: { owner_id: 777 } },
            details: { user: { surname: 'YYY' }, balance: 100 }
          }
        end

        let(:expected_message) do
          <<~JSON_OUTPUT.chomp
            {"tags":"shoryuken xxx_receiver","app":"#{config.app}","app_env":"#{config.app_env}","instance":"#{config.instance}","created_at":"#{timestamp.iso8601(3)}","ok":true,"details":{"user":{"id":111,"name":"XXX","surname":"YYY"},"sum":10,"owner_id":777,"balance":100}}\n
          JSON_OUTPUT
        end

        it do
          expect(call).to eq expected_message
        end
      end

      context 'exception with details' do
        let(:error) do
          e = StandardError.new('divided by 0')
          e.set_backtrace(
            [
              "luna_park/spec/luna_park/notifiers/tagged_log/tagged_formatter_spec.rb:151:in `/'",
              "luna_park/spec/luna_park/notifiers/tagged_log/tagged_formatter_spec.rb:151:in `block (4 levels) in <module:LunaPark>'",
              ".asdf/installs/ruby/2.5.1/lib/ruby/gems/2.5.0/gems/rspec-core-3.9.2/lib/rspec/core/memoized_helpers.rb:317:in `block (2 levels) in let'"
            ]
          )
          e
        end
        let(:msg) do
          {
            original_msg: error,
            details: { user: { surname: 'YYY' }, balance: 100 }
          }
        end

        let(:expected_message) do
          <<~JSON_OUTPUT.chomp
            {"tags":"shoryuken xxx_receiver","app":"#{config.app}","app_env":"#{config.app_env}","instance":"#{config.instance}","created_at":"#{timestamp.iso8601(3)}","ok":false,"error":{"class":"StandardError","message":"divided by 0","backtrace":"\\nluna_park/spec/luna_park/notifiers/tagged_log/tagged_formatter_spec.rb:151:in `/'\\nluna_park/spec/luna_park/notifiers/tagged_log/tagged_formatter_spec.rb:151:in `block (4 levels) in <module:LunaPark>'\\n.asdf/installs/ruby/2.5.1/lib/ruby/gems/2.5.0/gems/rspec-core-3.9.2/lib/rspec/core/memoized_helpers.rb:317:in `block (2 levels) in let'\\n"},"details":{"user":{"surname":"YYY"},"balance":100}}\n
          JSON_OUTPUT
        end

        it do
          expect(call).to eq expected_message
        end
      end

      context 'lunapark exception with details' do
        let(:error) do
          class UniquenessError < LunaPark::Errors::Business; end

          UniquenessError.new(message: 'error message', user: { xxx: 'yyyy' })
        end
        let(:msg) do
          {
            original_msg: error,
            details: { user: { surname: 'YYY' }, balance: 100 }
          }
        end

        let(:expected_message) do
          <<~JSON_OUTPUT.chomp
            {"tags":"shoryuken xxx_receiver","app":"#{config.app}","app_env":"#{config.app_env}","instance":"#{config.instance}","created_at":"#{timestamp.iso8601(3)}","ok":false,"error":{"class":"LunaPark::UniquenessError","message":"LunaPark::UniquenessError"},"details":{"message":"error message","user":{"xxx":"yyyy","surname":"YYY"},"balance":100}}\n
          JSON_OUTPUT
        end

        it do
          expect(call).to eq expected_message
        end
      end

      context 'hash message with details details' do
        let(:msg) do
          {
            original_msg: { user: { id: 111, name: 'XXX' }, sum: 10 },
            details: { details: { user: { surname: 'YYY' }, balance: 100 } }
          }
        end

        let(:expected_message) do
          <<~JSON_OUTPUT.chomp
            {"tags":"shoryuken xxx_receiver","app":"#{config.app}","app_env":"#{config.app_env}","instance":"#{config.instance}","created_at":"#{timestamp.iso8601(3)}","ok":true,"details":{"user":{"id":111,"name":"XXX","surname":"YYY"},"sum":10,"balance":100}}\n
          JSON_OUTPUT
        end

        it do
          expect(call).to eq expected_message
        end
      end
    end
  end
end
