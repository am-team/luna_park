# frozen_string_literal: true

require 'fakefs/spec_helpers'

module LunaPark
  module SubDomain
    module Foo
      class Bar
        def to_s
          'a'
        end
      end
    end

    class Service
      def call
        foo = Foo::Bar.new
        foo.to_s
      end

      def self.call
        new.call
      end
    end
  end

  RSpec.describe SubDomain::Service do
    let(:service) { described_class }

    describe '.call' do
      subject(:call) { service.call }

      it { is_expected.to eq 'a' }

      context '.b' do
        let(:instance) { instance_double(SubDomain::Foo::Bar, to_s: 'b') }
        let(:klass)    { class_double(SubDomain::Foo::Bar, new: instance) }

        before { service.const_set(:'Foo::Bar', klass) }

        it { is_expected.to eq 'b' }
      end
    end
  end
end
