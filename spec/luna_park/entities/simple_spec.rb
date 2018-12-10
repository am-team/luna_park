# frozen_string_literal: true

class User < LunaPark::Entities::Simple
  attr_accessor :email, :password
end

module LunaPark
  RSpec.describe Entities::Simple do
    let(:klass)    { User }
    let(:email)    { 'john.doe@email.com' }
    let(:password) { 'qwerty' }
    let(:user)     { klass }

    describe '.new' do
      subject(:obj) { klass.new arguments }

      context 'when all arguments are passed through initializer' do
        let(:arguments) do
          { email: email, password: password }
        end

        it { is_expected.to be_an_instance_of klass }

        it 'become object attributes' do
          expect(obj.email).to    eq email
          expect(obj.password).to eq password
        end
      end
    end
  end
end
