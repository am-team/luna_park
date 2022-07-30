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
    #     class Fatalism < LunaPark::Errors::Base
    #       message  'You cannot change your destiny', i18n: 'errors.fatalism'
    #       notify: :info
    #     end
    #   end
    #
    #   error = Error::Fatalism.new(choose: 'The first one')
    #   error.message # => 'You cannot change your destiny'
    #   error.message(lang: :ru) # => 'Вы не можете выбрать свою судьбу'
    #   error.details # => { :choose => "The first one" }
    #
    class Base < StandardError
      extend Extensions::Exceptions::Substitutive

      NOTIFY_VALUES           = [true, false, :debug, :info, :warning, :error, :fatal, :unknown].freeze
      NOTIFY_LEVELS           = %i[debug info warning error fatal unknown].freeze
      DEFAULT_NOTIFY_LEVEL    = :error

      private_constant :NOTIFY_VALUES, :NOTIFY_LEVELS, :DEFAULT_NOTIFY_LEVEL

      class << self
        # Explains how this error class will be notified
        #
        # @return [Boolean, Symbol] the behavior of the notification
        attr_reader :default_notify

        # What the key of the translation was selected for this error
        #
        # @return [NilClass, String] internationalization key
        attr_reader :i18n_key

        # Proc, that receives details hash: { detail_key => detail_value }
        #
        # @private
        attr_reader :__default_message_block__

        # Specifies the expected behavior of the error handler if an error
        # instance of this class is raised
        #
        # @param [Symbol] - set behavior of the notification (see #default_notify)
        #
        # @return [NilClass]
        def notify(lvl)
          self.default_notify = lvl unless lvl.nil?

          nil
        end

        # Specify default error message
        #
        # @param txt [String] - text of message
        # @param i18n [String] - internationalization key
        # @return [NilClass]
        def message(txt = nil, i18n_key: nil, i18n: nil, &default_message_block)
          @__default_message_block__ = block_given? ? default_message_block : txt && ->(_) { txt }
          @i18n_key = i18n || i18n_key
          nil
        end

        def inherited(inheritor)
          if __default_message_block__
            inheritor.message(i18n_key:, &__default_message_block__)
          elsif i18n_key
            inheritor.message(i18n_key:)
          end

          inheritor.default_notify = default_notify

          super
        end

        protected

        def default_notify=(notify)
          raise ArgumentError, "Unexpected notify value #{notify}" unless NOTIFY_VALUES.include? notify

          @default_notify = notify
        end
      end

      notify false

      # It is additional information which extends the notification message
      #
      # @example
      #   error = Fatalism.new('Message text', custom: 'Some important', foo: Foo.new )
      #   error.details # => {:custom=>"Some important", :foo=>#<Foo:0x000055b70ef6c370>}
      attr_reader :details

      # Create new error
      #
      # @param msg - Message text
      # @param notify - defines notifier behaviour (see #self.notify)
      # @param details - additional information to notifier
      #
      # @example without parameters
      #   error = Fatalism.new
      #   error.message     # => 'You cannot change your destiny'
      #   error.notify_lvl  # => :error
      #   error.notify?     # => true
      #
      # @example with custom parameters
      #   @error = Fatalism.new 'Forgive me Kuzma, my feet are frozen', notify: false
      #   error.message     # => 'Forgive Kuzma, my feet froze'
      #   error.notify_lvl  # => :error
      #   error.notify?     # => false
      #
      # TODO: make guards safe: remove these raises from exception constructor (from runtime)
      def initialize(msg = nil, notify: nil, **details)
        raise ArgumentError, "Unexpected notify value: #{notify}" unless notify.nil? || NOTIFY_VALUES.include?(notify)

        @message = msg
        @notify  = notify
        @details = details
        super(message)
      end

      # Should the handler send this notification ?
      #
      # @return [Boolean] it should be notified?
      #
      # @example notify is undefined
      #   error = LunaPark::Errors::Base
      #   error.notify # => false
      def notify?
        @notify || self.class.default_notify ? true : false
      end

      # Severity level for notificator
      #
      # @return [Symbol] expected notification level
      #
      # @example notify is undefined
      #   error = LunaPark::Errors::Base
      #   error.notify_lvl # => :error
      #
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
      #   LunaPark::Errors::Base.new.message # => 'LunaPark::Errors::Base'
      #
      # @example message is defined in class
      #   class WrongAnswerError < LunaPark::Errors::Base
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
      #   class FrostError < LunaPark::Errors::Base
      #     message 'Forgive Kuzma, my feet froze', i18n: 'errors.frost'
      #   end
      #
      #   error = FrostError.new
      #   error.message(locale: :ru) # => 'Прости Кузьма, замерзли ноги!'
      #
      # @example message is defined in class with block
      #   class WrongAnswerError < LunaPark::Errors::Base
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
      #   class WrongAnswerError < LunaPark::Errors::Base
      #     message i18n: 'errors.wrong_answer'
      #   end
      #
      #   error = WrongAnswerError.new(correct: 42, wrong: 420)
      #   error.message(locale: :de) # => "Die richtige Antwort ist '42', nicht '420'"
      #
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

        I18n.t(self.class.i18n_key, locale:, **details)
      end

      # @return [String] - Default message
      def build_default_message
        self.class.__default_message_block__&.call(details)
      end
    end
  end
end
