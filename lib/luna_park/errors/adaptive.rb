# frozen_string_literal: true

require 'luna_park/tools'
require 'luna_park/extensions/exceptions/substitutive'

require 'i18n' if LunaPark::Tools.gem_installed?('i18n')

module LunaPark
  module Errors
    # This class extends standard exception with a few things:
    # - define custom message with internalization key, if necessary
    # - setup handler behavior - raise or catch
    # - determine whether this error should be notified
    # - and if it should, define severity level
    # - send to handler not only message but also details
    #
    # @example Fatalism class
    #   module Errors
    #     class Fatalism < LunaPark::Errors::Adaptive
    #       message  'You cannot change your destiny', i18n_key: 'errors.fatalism'
    #       on_error action: :catch, notify: :info
    #     end
    #   end
    #
    #   error = Error::Fatalism.new(choose: 'The first one')
    #   error.message # => 'You cannot change your destiny'
    #   error.message(lang: :ru) # => 'Вы не можете выбрать свою судьбу'
    #   error.details # => { :choose => "The first one" }
    #
    class Adaptive < StandardError
      extend Extensions::Exceptions::Substitutive

      ACTION_VALUES           = %i[stop catch raise].freeze
      NOTIFY_VALUES           = [true, false, :debug, :info, :warning, :error, :fatal, :unknown].freeze
      NOTIFY_LEVELS           = %i[debug info warning error fatal unknown].freeze
      DEFAULT_NOTIFY_LEVEL    = :error

      private_constant :ACTION_VALUES, :NOTIFY_VALUES, :NOTIFY_LEVELS, :DEFAULT_NOTIFY_LEVEL

      class << self
        # Explains how this error class will be notified
        #
        # @return [Boolean, Symbol] the behavior of the notification
        attr_reader :default_notify

        # Default handler action if it's not specified
        #
        # @return [Symbol]
        attr_reader :default_action

        # What the key of the translation was selected for this error
        #
        # @return [NilClass, String] internationalization key
        attr_reader :i18n_key

        # Proc, that receives details hash: { detail_key => detail_value }
        #
        # @private
        attr_reader :default_message_block

        # Specifies the expected behavior of the error handler if an error
        # instance of this class is raised
        #
        # @param action [Symbol] action:
        #   - :stop - stop the application and don't give any feedback (
        #     Something has happened, but the user doesn't know what it is )
        #   - :catch - send a fail message to end-user, handler should catch it (usually it is used in business layer)
        #   - :raise - works like StandardError, and it is handled on application layer
        #
        # @param notify [Symbol] - set behavior of the notification (see #default_notify)
        #
        # @return [NilClass]
        def on_error(action: nil, notify: nil)
          self.default_action = action unless action.nil?
          self.default_notify = notify unless notify.nil?

          nil
        end

        # Specify default error message
        #
        # @param txt [String] - text of message
        # @param i18n_key [String] - internationalization key
        # @return [NilClass]
        def message(txt = nil, i18n_key: nil, &default_message_block)
          @default_message_block = block_given? ? default_message_block : txt && ->(_) { txt }
          @i18n_key = i18n_key
          nil
        end

        def inherited(inheritor)
          if default_message_block
            inheritor.message(i18n_key: i18n_key, &default_message_block)
          elsif i18n_key
            inheritor.message(i18n_key: i18n_key)
          end

          inheritor.default_action = default_action
          inheritor.default_notify = default_notify

          super
        end

        protected

        def default_action=(action)
          raise ArgumentError, "Unexpected action #{action}" unless ACTION_VALUES.include? action

          @default_action = action
        end

        def default_notify=(notify)
          raise ArgumentError, "Unexpected notify value #{notify}" unless NOTIFY_VALUES.include? notify

          @default_notify = notify
        end
      end

      on_error action: :raise, notify: false

      # It is additional information which extends the notification message
      #
      # @example
      #   error = Fatalism.new('Message text', custom: 'Some important', foo: Foo.new )
      #   error.details # => {:custom=>"Some important", :foo=>#<Foo:0x000055b70ef6c370>}
      attr_reader :details

      # Create new error
      #
      # @param msg - Message text
      # @param action - defines handler behavior (see #action)
      # @param notify - defines notifier behaviour (see #self.on_error)
      # @param details - additional information to notifier
      #
      # @example without parameters
      #   error = Fatalism.new
      #   error.message     # => 'You cannot change your destiny'
      #   error.action      # => :catch
      #   error.notify_lvl  # => :error
      #   error.notify?     # => true
      #
      # @example with custom parameters
      #   @error = Fatalism.new 'Forgive me Kuzma, my feet are frozen', action: :raise, notify: false
      #   error.message     # => 'Forgive Kuzma, my feet froze'
      #   error.action      # => :raise
      #   error.notify_lvl  # => :error
      #   error.notify?     # => false
      #
      # TODO: make guards safe: remove these raises from exception constructor (from runtime)
      def initialize(msg = nil, action: nil, notify: nil, **details)
        raise ArgumentError, "Unexpected action value: #{action}" unless action.nil? || ACTION_VALUES.include?(action)
        raise ArgumentError, "Unexpected notify value: #{notify}" unless notify.nil? || NOTIFY_VALUES.include?(notify)

        @message = msg
        @action  = action
        @notify  = notify
        @details = details
        super(message)
      end

      # Defined behavior for the error handler.
      #
      # - :stop - stop the application and don't give any feedback (
      #   Something has happened, but the user doesn't know what it is )
      # - :catch - send a fail message to end-user, handler should catch it (usually it is used in business layer)
      # - :raise - works like StandardError, and it is handled on application layer
      #
      # @return [Symbol] action
      #
      # @example action is undefined
      #   error = LunaPark::Errors::Adaptive
      #   error.action # => :raise
      #
      # @example action is defined in class
      #   class ExampleError < LunaPark::Errors::Adaptive
      #     on_error action: :catch
      #   end
      #   error = ExampleError.new
      #   error.action # => :catch
      #
      # @example action defined in an instance
      #   error = ExampleError.new nil, action: :stop
      #   error.action #=> :stop
      def action
        @action ||= self.class.default_action
      end

      # Should the handler send this notification ?
      #
      # @return [Boolean] it should be notified?
      #
      # @example notify is undefined
      #   error = LunaPark::Errors::Adaptive
      #   error.notify # => false
      #
      # @example action is defined in class
      #   class ExampleError < LunaPark::Errors::Adaptive
      #     on_error notify: :info
      #   end
      #   error = ExampleError.new
      #   error.notify? # => true
      #
      # @example action defined in an instance
      #   error = ExampleError.new nil, notify: false
      #   error.notify? #=> false
      def notify?
        @notify || self.class.default_notify ? true : false
      end

      # Severity level for notificator
      #
      # @return [Symbol] expected notification level
      #
      # @example notify is undefined
      #   error = LunaPark::Errors::Adaptive
      #   error.notify_lvl # => :error
      #
      # @example action is defined in class
      #   class ExampleError < LunaPark::Errors::Adaptive
      #     on_error notify: :info
      #   end
      #   error = ExampleError.new
      #   error.notify_lvl # => :info
      #
      # @example action defined in an instance
      #   error = ExampleError.new nil, notify: false
      #   error.notify_level #=> :error
      def notify_lvl
        return @notify                   if NOTIFY_LEVELS.include? @notify
        return self.class.default_notify if NOTIFY_LEVELS.include? self.class.default_notify

        DEFAULT_NOTIFY_LEVEL
      end

      # Error message
      #
      # The message text is defined in the following order:
      # 1. In the `initialize` method
      # 2. Translated message, if i18n key was settled in class (see `.message`)
      # 3. In the class method (see `.message`)
      #
      # @param locale [Symbol,String]
      # @return [String] message text
      #
      # @example message is not settled
      #   LunaPark::Errors::Adaptive.new.message # => 'LunaPark::Errors::Adaptive'
      #
      # @example message is defined in class
      #   class WrongAnswerError < LunaPark::Errors::Adaptive
      #     message 'Answer is 42'
      #   end
      #
      #   WrongAnswerError.new.message # => 'Answer is 42'
      #
      # @example message is in internatialization config
      #   # I18n YML
      #   # ru:
      #   #   errors:
      #   #     frost: Прости Кузьма, замерзли ноги!
      #
      #   class FrostError < LunaPark::Errors::Adaptive
      #     message 'Forgive Kuzma, my feet froze', i18n_key: 'errors.frost'
      #   end
      #
      #   error = FrostError.new
      #   error.message(locale: :ru) # => 'Прости Кузьма, замерзли ноги!'
      #
      # @example message is defined in class with block
      #   class WrongAnswerError < LunaPark::Errors::Adaptive
      #     message { |details| "Answer is '#{details[:correct]}' - not '#{details[:wrong]}'" }
      #   end
      #
      #   error = WrongAnswerError.new(correct: 42, wrong: 420)
      #   error.message # => "Answer is '42' - not '420'"
      #
      # @example message is in internalization config with i18n interpolation
      #   # I18n YML
      #   # de:
      #   #   errors:
      #   #     wrong_answer: Die richtige Antwort ist '%{correct}', nicht '%{wrong}'
      #
      #   class WrongAnswerError < LunaPark::Errors::Adaptive
      #     message i18n_key: 'errors.wrong_answer'
      #   end
      #
      #   error = WrongAnswerError.new(correct: 42, wrong: 420)
      #   error.message(locale: :de) # => "Die richtige Antwort ist '42', nicht '420'"
      #
      # @example action defined in an instance
      #   error = TemperatureValueError.new 'Please do not use fahrenheits'
      #   error.message #=> 'Please do not use fahrenheits'
      def message(locale: nil)
        return @message if @message

        default_message = build_default_message
        localized_message(locale, show_error: default_message.nil?) || default_message || self.class.name
      end

      private

      # Return translation of an error message if 18n_key is defined
      # if `show_error: true` and translation is missing, will return string 'translation missing: path'
      # if `show_error: false` and translation is missing, will return nil
      #
      # @param locale [Symbol] - specified locale
      # @return [String] - Translated text
      def localized_message(locale = nil, show_error:)
        return unless self.class.i18n_key
        return unless show_error || I18n.exists?(self.class.i18n_key)

        I18n.t(self.class.i18n_key, locale: locale, **details)
      end

      # @return [String] - Default message
      def build_default_message
        self.class.default_message_block&.call(details)
      end
    end
  end
end
