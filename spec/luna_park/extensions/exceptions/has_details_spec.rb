# frozen_string_literal: true

require 'luna_park/extensions/exceptions/has_details'

module ExtensionsExceptionsHasDetailsSpec
  class MyException < RuntimeError
    extend LunaPark::Extensions::Exceptions::HasDetails

    details :name, :title

    def default_message
      "User `#{name}` is not allowed to edit `#{title}`"
    end
  end
end

module LunaPark
  RSpec.describe Extensions::Exceptions::HasDetails do
    subject(:exception) { ExtensionsExceptionsHasDetailsSpec::MyException.new(name: 'John Doe', title: 'The Book') }

    it 'has described details methods' do
      expect(raise_n_catch(exception).name).to  eq 'John Doe'
      expect(raise_n_catch(exception).title).to eq 'The Book'
    end

    describe '#details' do
      context 'when created with all details' do
        subject(:exception) { ExtensionsExceptionsHasDetailsSpec::MyException.new(name: 'John Doe', title: 'The Book') }

        it 'returns described fields' do
          expect(raise_n_catch(exception).details).to eq(name: 'John Doe', title: 'The Book')
        end
      end

      context 'when created without some detail' do
        subject(:exception) { ExtensionsExceptionsHasDetailsSpec::MyException.new(name: 'John Doe') }

        it 'returns described fields' do
          expect(raise_n_catch(exception).details).to eq(name: 'John Doe', title: nil)
        end
      end
    end


    context 'when created without message' do
      subject(:exception) { ExtensionsExceptionsHasDetailsSpec::MyException.new(name: 'John Doe', title: 'The Book') }

      it 'has default message' do
        expect(raise_n_catch(exception).message).to eq 'User `John Doe` is not allowed to edit `The Book`'
      end
    end

    context 'when created with message' do
      subject(:exception) { ExtensionsExceptionsHasDetailsSpec::MyException.new('Nope!', name: 'John Doe', title: 'The Book') }

      it 'has given message' do
        expect(raise_n_catch(exception).message).to eq 'Nope!'
      end
    end

    def raise_n_catch(exception)
      raise exception
    rescue exception.class => e
      e
    end
  end
end
