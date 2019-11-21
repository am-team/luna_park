# frozen_string_literal: true

module LunaPark
  module Gateways
    module Http
      module Handlers
        RSpec.describe Rest do
          let(:handler) { described_class.new }

          let(:title)     { 'custom action' }
          let(:request)   { double }

          describe '#error' do
            let(:response) { double(code: 403) }

            subject { handler.error(title, response: response, request: request) }
            it { expect { subject }.to raise_error Http::Errors::Rest::Diagnostic }

            context 'when error skipped' do
              let(:handler) { described_class.new skip_errors: [403] }

              it { expect { subject }.to_not raise_error }
            end
          end

          describe '#timeout_error' do
            subject { handler.timeout_error(title, request: request) }
            it { expect { subject }.to raise_error Http::Errors::Rest::Timeout }

            context 'when error skipped' do
              let(:handler) { described_class.new skip_errors: [:timeout] }

              it { expect { subject }.to_not raise_error }
            end
          end
        end
      end
    end
  end
end
