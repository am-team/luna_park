# frozen_string_literal: true

require 'luna_park/use_cases/service'

module LunaPark
  RSpec.describe UseCases::Service do
    subject(:service) { described_class.new }

    it 'should has errors' do
      is_expected.to be_a Extensions::HasErrors
    end

    it 'should be callable' do
      expect(described_class).to be_a Extensions::Callable
    end
  end
end
