# frozen_string_literal: true

module LunaPark
  module Gateways
    module Http
      module Handlers
        RSpec.describe Default do
          let(:handler) { described_class.new }

          let(:title)     { 'custom action' }
          let(:request)   { double }

          describe '#error' do
            subject(:error) { handler.error(title, response: response, request: request) }

            let(:response) { double(code: 403) }

            it { expect { error }.to raise_error Http::Errors::Default::Diagnostic }

            context 'when error skipped' do
              let(:handler) { described_class.new skip_errors: [403] }

              it { expect { error }.to_not raise_error }
            end
          end

          describe '#timeout_error' do
            subject(:timeout_error) { handler.timeout_error(title, request: request) }

            it { expect { timeout_error }.to raise_error Http::Errors::Default::Timeout }

            context 'when error skipped' do
              let(:handler) { described_class.new skip_errors: [:timeout] }

              it { expect { timeout_error }.to_not raise_error }
            end
          end
        end
      end
    end
  end
end
