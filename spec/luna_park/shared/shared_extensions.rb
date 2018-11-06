# frozen_string_literal: true

RSpec.configure do |rspec|
  # This config option will be enabled by default on RSpec 4,
  # but for reasons of backwards compatibility, you have to
  # set it on RSpec 3.
  #
  # It causes the host group and examples to inherit metadata
  # from the shared context.
  rspec.shared_context_metadata_behavior = :apply_to_host_groups
end

RSpec.shared_context 'shared_extensions', shared_context: :metadata do
  shared_examples 'callable' do
    it 'has callable instance methods' do
      expect(described_class).to be_a LunaPark::Extensions::Callable::InstanceMethods
    end

    it 'has callable class methods' do
      expect(described_class).to be_a LunaPark::Extensions::Callable::ClassMethods
    end
  end

  shared_examples 'runnable' do
    it 'has runnable methods' do
      # expect(described_class).to be_kind_of LunaPark::Extensions::Callable
      true
    end
  end

  shared_examples 'attributable' do
    it 'has attributable methods' do
      # expect(described_class).to be_kind_of LunaPark::Extensions::Callable
      true
    end
  end
end
