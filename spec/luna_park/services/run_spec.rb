# frozen_string_literal: true

require_relative '../shared/shared_extensions'

RSpec.describe LunaPark::Services::Run do
  include_context 'shared_extensions'

  it_behaves_like 'runnable'
  it_behaves_like 'attributable'
end
