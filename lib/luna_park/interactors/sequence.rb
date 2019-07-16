# frozen_string_literal: true

require_relative '../errors'
require_relative '../extensions/attributable'
require_relative '../extensions/callable'

module LunaPark
  module Interactors
    # Interactor for describe UseCase as scenario (or sequence of actions)
    #   Implementation should provide high-level description of buisnes-logic and buisnes-logic failures
    #
    # @example
    #  module Errors
    #    class Processing << LunaPark::Errors::Processing; end
    #    class NotEnoughMoney < Processing
    #      # ...
    #    end
    #  end
    #
    #  module Scenarios
    #    class Withdrawal < LunaPark::Interactors::Sequence
    #      attr_accessor :account, :charge # will be used for initialize object `new(balance:, user:)`
    #
    #      def call!
    #        Reositories::Balance.transaction do
    #          balance = Reositories::Balance.find(account.id)
    #
    #          guard_balance balance, charge # buisnes-logic check
    #
    #          transactions = WithdrawalTransactionsFactory.call(account: account, charge: charge)
    #          Reositories::Transaction.create_many(transactions)
    #        end
    #      end
    #
    #      private
    #
    #      def on_failure(failure)
    #        case failure # also accessible as getter
    #        when Errors::ImportantError then BugTracker.warning(failure)
    #        end
    #      end
    #
    #      def guard_balance(balance, charge)
    #        return if balance >= charge
    #
    #        raise Errors::NotEnoughMoney.new(account: account, balance: balance, charge: charge)
    #      end
    #    end
    #  end
    #
    #  scenario = Scenarios::Withdrawal.call(account: Account.new(account_params), charge: Money.new(charge_params))
    #
    #  if scenario.failure?
    #    scenario.failure # => NotEnoughMoney
    #    scenario.failure.message # => "Account user 42 tryes to withdraw 1000 USD while has only 0.01 USD"
    #  else
    #    scenario.data # =>
    #  end
    class Sequence
      include Extensions::Attributable
      extend  Extensions::Callable

      attr_reader :state, :failure, :data

      INIT    = :initialized
      SUCCESS = :success
      FAILURE = :failure

      def initialize(attrs = {})
        set_attributes attrs
        @state   = INIT
        @failure = nil
        @data    = nil
      end

      # :nocov:

      # @abstract
      def call!
        raise Errors::AbstractMethod
      end
      # :nocov:

      def call
        catch { @data = call! }
        self
      end

      def failure?
        state == FAILURE
      end

      def success?
        state == SUCCESS
      end

      # :nocov:

      # @deprecated
      def fail_message
        failure&.message
      end
      # :nocov:

      alias fail    failure
      alias failed? failure?
      alias fail?   failure?
      alias succeed? success?

      class << self
        def call(*attrs)
          new(*attrs).tap(&:call)
        end
      end

      private

      def catch
        yield
        @state = SUCCESS
      rescue Errors::Processing => e
        @state   = FAILURE
        @failure = e
        on_fail(e)
      end

      # @abstract
      def on_fail(_processing_exception); end
    end
  end
end
