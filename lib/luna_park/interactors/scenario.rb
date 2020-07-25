# frozen_string_literal: true

require 'luna_park/errors'
require 'luna_park/tools'
require 'luna_park/notifiers/log'
LunaPark::Tools.if_gem_installed('bugsnag') { require 'luna_park/notifiers/bugsnag' }
require 'luna_park/extensions/attributable'
require 'luna_park/extensions/callable'

module LunaPark
  module Interactors
    # The main goal of the interactor is a high-level description
    # of the business process. This specific implementation
    # is based on the ideas of Ivar Jacobson from his article
    # Ivar Jacobson: Use Case 2.0.
    #
    # @example Create new user
    #   module Errors
    #     # To catch the errors, it's should be the error must
    #     # be inherited from the class LunaPark::Errors::Processing
    #     class UserAlreadyExists < LunaPark::Errors::Processing
    #       message 'Sorry user with this email already created'
    #       on_error action: :catch, notify: :info
    #     end
    #   end
    #
    #   class CreateUser < Scenario
    #     attr_accessor :email, :password
    #
    #     def call!
    #       user          = Entities::User.new
    #       user.email    = email
    #       user.password = Service::Encode.call(password)
    #
    #       DB.transaction do
    #        error Errors::UserAlreadyExists if Repo::Users.exists?(user)
    #        Repo::Users.create(user)
    #       end
    #     end
    #   end
    class Scenario
      include Extensions::Attributable
      extend  Extensions::Callable

      DEFAULT_NOTIFIER = Notifiers::Log.new

      private_constant :DEFAULT_NOTIFIER

      INIT    = :initialized
      SUCCESS = :success
      FAIL    = :fail

      private_constant :INIT, :SUCCESS, :FAIL

      # What status is the process of doing the work under the scenario.
      # It can be :initialized, :success, :failure
      #
      # @example when work just started
      #   scenario = Scenario.new
      #   scenario.state # => :initialized
      #
      # @example on fail
      #   scenario.call  # Something went wrong
      #   scenario.state # => :failure
      #
      # @example on success
      #   scenario.call
      #   scenario.state # => :success
      attr_reader :state

      # If a failure occurs during the scenario, then this attribute will contain this error
      # Else it's nil.
      #
      # @example when work just started
      #   scenario = Scenario.new
      #   scenario.fail # => nil
      #
      # @example on fail
      #   class Fail < Errors::Processing; end
      #   class FailScenario < Scenario
      #     def call!
      #       raise Fail
      #       :result
      #     end
      #   end
      #
      #   scenario = FailScenario.new
      #   scenario.call  # Something went wrong
      #   scenario.fail  # => #<Fail: Fail>
      #
      # @example on success
      #   scenario.call
      #   scenario.fail # => nil
      attr_reader :failure

      # The result obtained during the execution of the scenario.
      # It's nil on failure scenario.
      #
      # @example when work just started
      #   scenario = Scenario.new
      #   scenario.data # => nil
      #
      # @example on fail
      #   scenario.call  # Something went wrong
      #   scenario.data  # => nil
      #
      # @example on success
      #   class SuccessScenario < Scenario
      #     def call!
      #       :result
      #     end
      #   end
      #
      #   scenario = SuccessScenario.new
      #   scenario.call
      #   scenario.data # => :result
      attr_reader :data

      # Current locale
      attr_reader :locale

      # Initialize new scenario
      #
      # @param notifier - custom notifier for the current instance of scenario
      # @param locale   - custom locale for the current instance of scenario
      # @param attrs    - the parameters that are needed to implement the scenario, usually the request model
      #
      # @example without parameters
      #   class SayHello < Scenario
      #     attr_accessor :first_name, :last_name
      #
      #     def call!
      #       t('hello_my_nme_is', first_name: first_name, last_name: last_name)
      #     end
      #   end
      #
      #   hello = Scenario.new first_name: 'John', last_name: 'Doe'
      #   hello.notifier    # => Notifiers::Log
      #   hello.locale      # => nil
      #   hello.first_name  # => 'John'
      #   hello.last_name   # => 'Doe'
      #   hello.call!       # => 'Hello my name is John Doe'
      #
      # @example with custom parameters
      #   hello = Scenario.new first_name: 'John', last_name: 'Doe', notifier: Notifier::Bugsnag, locale: :ru
      #   hello.notifier    # => Notifiers::Bugsnag
      #   hello.locale      # => :ru
      #   hello.first_name  # => 'John'
      #   hello.last_name   # => 'Doe'
      #   hello.call!       # => 'Добрый день, меня зовут John Doe'
      def initialize(notifier: nil, locale: nil, **attrs)
        set_attributes attrs
        @data     = nil
        @failure  = nil
        @locale   = locale
        @notifier = notifier
        @state    = INIT
      end

      # You must define this action and describe all business logic here.
      # When you run this method - it run as is, and does not change scenario instance.
      #
      # @abstract
      #
      # @example Fail way
      #   class Shot < Scenario
      #     attr_accessor :lucky_mode
      #
      #     def call!
      #       raise YouDied, 'Always something went wrong' unless lucky_mode
      #       'All good'
      #     end
      #   end
      #
      #   bad_day = Shot.new lucky_mode: false
      #   bad_day.call! # it raise - SomethingWentWrong: Always something went wrong
      #   bad_day.state # => :initialized
      #
      # @example Main way
      #   good_day = Shot.new lucky_mode: true
      #   good_day.call! # => 'All good'
      #   good_day.state # => :initialized
      #
      # @example Russian roulette
      #   # `.call!` usually use for "scenario in scenario"
      #   class RussianRoulette < Scenario
      #     def call!
      #       [true, true, true, true, true, false].shuffle do |bullet|
      #         Shot.call! lucky_mode: bullet
      #       end
      #     end
      #   end
      def call!
        raise Errors::AbstractMethod
      end

      # You must define this action and describe all business logic here.
      # When you run this method - it run as is, and does not change scenario instance.
      #
      # @abstract
      #
      # @example fail way
      #   class YouDied < Errors::Processing; end
      #
      #   class Shot < Scenario
      #     attr_accessor :lucky_mode
      #
      #     def call!
      #       raise YouDied, 'Always something went wrong' unless lucky_mode
      #       'All good'
      #     end
      #   end
      #
      #   bad_day = Shot.new lucky_mode: false
      #   bad_day.call         # => #<Shot:0x000055cbee4bc070...>
      #   bad_day.success?     # => false
      #   bad_day.fail?        # => true
      #   bad_day.data         # => nil
      #   bad_day.state        # => :failure
      #   bad_day.fail         # => #<YouDied:0x000055cbee4bc071...>
      #   bad_day.fail_message # => ''
      #
      #   @example main way
      #
      #   good_day = Shot.new lucky_mode: true
      #   good_day.call! # => 'All good'
      #   good_day.state # => :initialized
      #
      # @example Russian roulette
      #   class RussianRoulette < Scenario
      #     def call!
      #       [true, true, true, true, true, false].shuffle do |bullet|
      #         Shot.call! lucky_mode: bullet
      #       end
      #     end
      #   end
      def call
        catch { @data = call! }
        self
      end

      # Return notifier
      def notifier
        @notifier ||= self.class.default_notifier
      end

      # @return [Boolean] true if the scenario runs unsuccessfully
      def fail?
        state == FAIL
      end

      alias failure? fail?

      # @return [Boolean] true if the scenario runs successfully
      def success?
        state == SUCCESS
      end

      alias succeed? success?

      # @return [String] fail message
      def failure_message(locale: nil)
        failure&.message(locale: locale || self.locale)
      end

      class << self
        # @return Default notifier
        def default_notifier
          @default_notifier ||= DEFAULT_NOTIFIER
        end

        # Set notifier for this class
        #
        # @example set notifier
        #   class Foobar < Scenario
        #     notify_with Notifier::Bugsnag
        #
        #     def call!
        #       true
        #     end
        #   end
        #
        #   Foobar.default_notifier # => Notifier::Bugsnag
        #   Foobar.new.notifier     # => Notifier::Bugsnag
        def notify_with(notifier)
          @default_notifier = notifier
        end
      end

      private

      def catch
        yield
      rescue Errors::Adaptive => e
        @state = FAIL
        notify_error e if e.notify?
        handle_error e
      else
        @state = SUCCESS
      end

      def notify_error(error)
        notifier.post error, lvl: error.notify_lvl
      end

      def handle_error(error)
        case error.action
        when :stop  then on_stop
        when :catch then on_catch(error)
        when :raise then on_raise(error)
        else raise ArgumentError, "Unknown error action #{error.action}"
        end
      end

      def on_stop
        nil
      end

      def on_catch(error)
        @failure = error
      end

      def on_raise(error)
        raise error
      end
    end
  end
end
