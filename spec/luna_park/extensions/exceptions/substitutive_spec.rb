# frozen_string_literal: true

require 'luna_park/extensions/exceptions/substitutive'

module ExtensionsExceptionsSubstitutiveSpec
  class SubstitutiveError < StandardError
    extend LunaPark::Extensions::Exceptions::Substitutive
  end

  class SubstitutiveWithArgs < StandardError
    extend LunaPark::Extensions::Exceptions::Substitutive

    attr_reader :comment

    def initialize(msg = nil, comment = nil)
      @comment = comment
      super(msg)
    end
  end

  class SubstitutiveWithOptsAndBuiltMessage < StandardError
    extend LunaPark::Extensions::Exceptions::Substitutive

    attr_reader :comment

    def initialize(msg = nil, comment: nil)
      @comment = comment
      super(msg || build_message)
    end

    def build_message
      "Comment: #{comment.inspect}"
    end
  end

  class << self
    ORIGIN_EXCEPTION = StandardError.new('OriginMsg')

    def raise_origin_exception
      raise ORIGIN_EXCEPTION
    end

    def raise_substitutive_exception
      raise_origin_exception
    rescue StandardError => e
      raise SubstitutiveError.substitute(e)
    end

    def raise_substitutive_with_msg
      raise_origin_exception
    rescue StandardError => e
      raise SubstitutiveError.substitute(e, 'NewMsg')
    end

    def raise_substitutive_with_args
      raise_origin_exception
    rescue StandardError => e
      raise SubstitutiveWithArgs.substitute(e, 'NewMsg', 'Oy vey!')
    end

    def raise_substitutive_with_opts
      raise_origin_exception
    rescue StandardError => e
      raise SubstitutiveWithOptsAndBuiltMessage.substitute(e, comment: 'Oy vey!')
    end
  end
end

module LunaPark
  RSpec.describe Extensions::Exceptions::Substitutive do
    let(:origin_exception) { exception { ExtensionsExceptionsSubstitutiveSpec.raise_origin_exception } }

    context 'with any args,' do
      let(:substituted_exception) { exception { ExtensionsExceptionsSubstitutiveSpec.raise_substitutive_exception } }

      it 'backtrace starts from the origin exception backtrace' do
        expect(substituted_exception.backtrace.first).to be origin_exception.backtrace.first
      end

      it 'includes backtrace of the origin exception' do
        expect(substituted_exception.backtrace.map { |p| p.split(':').last }).to include 'in `raise_origin_exception\''
      end

      it 'includes backtrace of the substitutive exception' do
        expect(substituted_exception.backtrace.map { |p| p.split(':').last }).to include 'in `raise_substitutive_exception\''
      end

      it 'contains the origin exception object' do
        expect(substituted_exception.origin).to be origin_exception
      end
    end

    context 'when substituted with new message,' do
      let(:substituted_exception) { exception { ExtensionsExceptionsSubstitutiveSpec.raise_substitutive_with_msg } }

      it 'has added message' do
        expect(substituted_exception.message).to eq 'NewMsg'
      end
    end

    context 'when substituted with additional args,' do
      let(:substituted_exception) { exception { ExtensionsExceptionsSubstitutiveSpec.raise_substitutive_with_args } }

      it 'has added message' do
        expect(substituted_exception.message).to eq 'NewMsg'
      end

      it 'additional named args was performed' do
        expect(substituted_exception.comment).to eq 'Oy vey!'
      end
    end

    context 'when substituted with additional named args AND built message,' do
      let(:substituted_exception) { exception { ExtensionsExceptionsSubstitutiveSpec.raise_substitutive_with_opts } }

      it 'has built message' do
        expect(substituted_exception.message).to eq 'Comment: "Oy vey!"'
      end

      it 'additional named args was performed' do
        expect(substituted_exception.comment).to eq 'Oy vey!'
      end
    end

    def exception
      yield
      nil
    rescue => e # rubocop:disable Style/RescueStandardError:
      e
    end
  end
end
