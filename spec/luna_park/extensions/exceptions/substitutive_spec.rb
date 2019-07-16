# frozen_string_literal: true

require_relative '../../../../lib/luna_park/extensions/exceptions/substitutive'

module ExtensionsExceptionsSubstitutiveSpec
  class RegularError < StandardError; end

  class SubstitutiveError < StandardError
    extend LunaPark::Extensions::Exceptions::Substitutive
  end

  class << self
    ORIGIN_EXCEPTION = StandardError.new('Foo')

    def raise_origin_exception
      raise ORIGIN_EXCEPTION
    end

    def raise_replaced_exception
      raise_origin_exception
    rescue StandardError
      raise RegularError
    end

    def raise_substitutive_exception
      raise_origin_exception
    rescue StandardError => e
      raise SubstitutiveError.substitute(e)
    end
  end
end

module LunaPark
  RSpec.describe Extensions::Exceptions::Substitutive do
    let(:origin_exception)      { catch { ExtensionsExceptionsSubstitutiveSpec.raise_origin_exception } }
    let(:replaced_exception)    { catch { ExtensionsExceptionsSubstitutiveSpec.raise_replaced_exception } }
    let(:substituted_exception) { catch { ExtensionsExceptionsSubstitutiveSpec.raise_substitutive_exception } }

    describe 'substitutive exception' do
      it 'has name of origin exception' do
        expect(substituted_exception.message).to be origin_exception.message
      end

      it 'backtrace starts from origin exception backtrace' do
        expect(substituted_exception.backtrace.first).to be origin_exception.backtrace.first
      end

      it 'includes backtrace of origin exception' do
        expect(substituted_exception.backtrace.map { |p| p.split(':').last }).to include 'in `raise_origin_exception\''
      end

      it 'includes backtrace of new exception' do
        expect(substituted_exception.backtrace.map { |p| p.split(':').last }).to include 'in `raise_substitutive_exception\''
      end

      it 'contains origin exception object' do
        expect(substituted_exception.origin).to be origin_exception
      end
    end

    describe 'replaced exception' do
      it 'not includes backtrace of origin exception' do
        expect(replaced_exception.backtrace).not_to include origin_exception.backtrace.first
      end
    end

    def catch
      yield
    rescue => e # rubocop:disable Style/RescueStandardError:
      e
    end
  end
end
