# frozen_string_literal: true

module EntitiesSimpleCpec
  class User < LunaPark::Entities::Simple
    attr_accessor :email, :password

    def ==(other)
      email == other.email.to_s && password == other.password.to_s
    end
  end
end

module LunaPark
  RSpec.describe Entities::Simple do
    subject(:object) { EntitiesSimpleCpec::User.new attributes }

    let(:object_abstract) { Entities::Simple.new }

    let(:attributes) { { email: email, password: password } }
    let(:email)    { 'john.doe@email.com' }
    let(:password) { 'qwerty' }

    describe '.new' do
      context 'when all attributes are passed through initializer' do
        let(:attributes) { { email: email, password: password } }

        it { is_expected.to be_an_instance_of EntitiesSimpleCpec::User }

        it 'become object attributes' do
          expect(object.email).to    eq email
          expect(object.password).to eq password
        end
      end
    end

    describe '#.eql?' do
      it 'returns true when expected' do
        expect(object).to be_eql object.dup
      end

      it 'returns true when type missmatch' do
        expect(object).not_to be_eql OpenStruct.new(attributes)
      end

      it 'is abstract' do
        expect { object_abstract.eql?(object_abstract) }.to raise_error Errors::AbstractMethod
      end
    end

    describe '#==' do
      it { expect { object_abstract == object_abstract.dup }.to raise_error Errors::AbstractMethod }
    end

    describe '#serialize' do
      it { expect { object_abstract.serialize }.to raise_error Errors::AbstractMethod }

      it 'calls #to_h' do
        expect(object).to receive(:to_h)
        object.serialize
      end
    end

    describe '#to_h' do
      it { expect { object_abstract.to_h }.to raise_error Errors::AbstractMethod }
    end
  end
end
