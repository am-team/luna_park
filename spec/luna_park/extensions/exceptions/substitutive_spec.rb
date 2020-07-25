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
end

module LunaPark
  RSpec.describe Extensions::Exceptions::Substitutive do
    SPEC = ExtensionsExceptionsSubstitutiveSpec

    context 'with any args,' do
      def origin_exception
        @origin_exception ||=
          begin
            raise StandardError, 'OriginMsg'
          rescue StandardError => e
            e
          end
      end

      def substituted_exception
        origin_exception # touch the memorisation to prevent mistakes
        @substituted_exception ||=
          begin
            raise SPEC::SubstitutiveError.substitute(origin_exception)
          rescue SPEC::SubstitutiveError => e
            e
          end
      end

      it 'backtrace starts from the origin exception backtrace' do
        expect(substituted_exception.backtrace.first).to eq origin_exception.backtrace.first
      end

      it 'includes backtrace of the substitutive exception' do
        expect(substituted_exception.backtrace.map { |p| p.split(':').last }).to include 'in `substituted_exception\''
      end

      it 'contains the origin exception object' do
        expect(substituted_exception.origin).to be origin_exception
      end
    end

    context 'when substituted with new message,' do
      let(:substituted_exception) do
        begin
          raise StandardError, 'OriginMsg'
        rescue StandardError => e
          raise SPEC::SubstitutiveError.substitute(e, 'NewMsg')
        end
      rescue SPEC::SubstitutiveError => e
        e
      end

      it 'has added message' do
        expect(substituted_exception.message).to eq 'NewMsg'
      end
    end

    context 'when substituted with additional args,' do
      let(:substituted_exception) do
        begin
          raise StandardError, 'OriginMsg'
        rescue StandardError => e
          raise SPEC::SubstitutiveWithArgs.substitute(e, 'NewMsg', 'Oy vey!')
        end
      rescue SPEC::SubstitutiveWithArgs => e
        e
      end

      it 'has added message' do
        expect(substituted_exception.message).to eq 'NewMsg'
      end

      it 'additional named args was performed' do
        expect(substituted_exception.comment).to eq 'Oy vey!'
      end
    end

    context 'when substituted with additional named args AND built message,' do
      let(:substituted_exception) do
        begin
          raise StandardError, 'OriginMsg'
        rescue StandardError => e
          raise SPEC::SubstitutiveWithOptsAndBuiltMessage.substitute(e, comment: 'Oy vey!')
        end
      rescue SPEC::SubstitutiveWithOptsAndBuiltMessage => e
        e
      end

      it 'has built message' do
        expect(substituted_exception.message).to eq 'Comment: "Oy vey!"'
      end

      it 'additional named args was performed' do
        expect(substituted_exception.comment).to eq 'Oy vey!'
      end
    end

    context 'when substitutes substitutive exception,' do
      let(:original_substitutive) do
        raise SPEC::SubstitutiveError, 'OriginMsg'
      rescue SPEC::SubstitutiveError => e
        e
      end

      let(:substituted_exception) do
        raise original_substitutive
      rescue SPEC::SubstitutiveError => e
        e
      end

      it 'new exception has original backtrace' do
        expect(substituted_exception.backtrace).to be original_substitutive.backtrace
      end

      it 'origin backtrace is not nil' do
        expect(original_substitutive.backtrace).not_to be_nil
      end

      it 'substituted backtrace is not nil' do
        expect(substituted_exception.backtrace).not_to be_nil
      end
    end
  end
end
