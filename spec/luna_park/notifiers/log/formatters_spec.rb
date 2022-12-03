# frozen_string_literal: true

require 'luna_park/notifiers/log'

module LunaPark
  RSpec.describe Notifiers::Log::Formatters do
    let(:message) { 'Task is finished' }
    let(:details) { { duration: 0.67, user: { uid: 'uid', name: 'John' } } }
    subject(:call) { formatter.call(message.class, message, details) }

    describe 'SINGLE' do
      let(:formatter) { Notifiers::Log::Formatters::SINGLE }

      context 'without details' do
        subject(:call) { formatter.call(message.class, message) }

        it 'returns only message text' do
          is_expected.to eq '#<String> Task is finished'
        end
      end

      context 'with details' do
        it 'returns message text with details' do
          is_expected.to eq '#<String> Task is finished {:duration=>0.67, :user=>{:uid=>"uid", :name=>"John"}}'
        end
      end
    end

    describe 'JSON' do
      let(:formatter) { Notifiers::Log::Formatters::JSON }

      it 'returns only message text' do
        is_expected.to eq '{"class":"String","message":"Task is finished","details":{"duration":0.67,"user":{"uid":"uid","name":"John"}}}'
      end
    end

    describe 'MULTILINE' do
      let(:formatter) { Notifiers::Log::Formatters::MULTILINE }

      it 'returns message with details in the form of a hash divided into several lines' do
        is_expected.to eq <<~MULTILINE.chomp # heredoc has newline symbol at the end, chomp it
          {:class=>String,
           :message=>"Task is finished",
           :details=>{:duration=>0.67, :user=>{:uid=>"uid", :name=>"John"}}}\n
        MULTILINE
      end
    end

    describe 'PRETTY_JSON' do
      let(:formatter) { Notifiers::Log::Formatters::PRETTY_JSON }

      it 'returns message with details in the form of a json divided into several lines' do
        is_expected.to eq <<~JSON_OUTPUT.chomp # heredoc has newline symbol at the end, chomp it
          {
            "class": "String",
            "message": "Task is finished",
            "details": {
              "duration": 0.67,
              "user": {
                "uid": "uid",
                "name": "John"
              }
            }
          }
        JSON_OUTPUT
      end
    end
  end
end
