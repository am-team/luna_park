require_relative '../shared/shared_extensions'

module LunaPark
  RSpec.describe Services::Run do
    include_context 'shared_extensions'

    it_behaves_like 'runnable'
    it_behaves_like 'attributable'
  end
end