require_relative '../shared/shared_extensions'

RSpec.describe LunaPark::Services::Call do
  include_context 'shared_extensions'

  it_behaves_like 'callable'
  it_behaves_like 'attributable'
end