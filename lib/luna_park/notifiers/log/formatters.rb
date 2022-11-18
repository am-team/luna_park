# frozen_string_literal: false

require 'pp'
require 'json'

module LunaPark
  module Notifiers
    class Log
      module Formatters
        # Fomatter - callable object to format log messages. Out of the box there are four types:

        # - SINGLE - output is a single line string message.
        #     notifier = LunaPark::Notifiers::Log.new(formatter: LunaPark::Notifiers::Log::Formatters::SINGLE)
        #     notifier.info('You hear', dog: 'wow', cats: {chloe: 'mow', timmy: 'mow'})
        #
        #     # I, [2022-09-29T10:51:15.753646 #28763]  INFO -- : String - You hear {:dog=>"wow", :cats=>{:chloe=>"mow", :timmy=>"mow"}}
        #
        SINGLE = lambda do |klass, message, details = {}|
          details.empty? ? "#<#{klass}> #{message}" : "#<#{klass}> #{message} #{details}"
        end

        # - MULTILINE - this format may become more preferred for development mode.
        #     notifier = LunaPark::Notifiers::Log.new(formatter: LunaPark::Notifiers::Log::Formatters::MULTILINE)
        #     notifier.info('You hear', dog: 'wow', cat: {timmy:'purr'}, cow: 'moo', duck: 'quack', horse: 'yell' )
        #
        #     # I, [2022-09-29T10:56:21.463211 #28763]  INFO -- : {:class=>String,
        #     # :message=>"You hear",
        #     # :details=>
        #     # {:dog=>"wow",
        #     # :cat=>{:timmy=>"purr"},
        #     # :cow=>"moo",
        #     # :duck=>"quack",
        #     # :horse=>"yell"}}
        MULTILINE = lambda do |klass, message, details = {}|
          PP.pp({ class: klass, message: message, details: details }, '')
        end

        # - JSON - this format should be good choose for logger which be processed by external logger system
        #     notifier = LunaPark::Notifiers::Log.new(formatter: LunaPark::Notifiers::Log::Formatters::JSON)
        #     notifier.info('You hear', dog: 'wow', cats: {chloe: 'mow', timmy: 'mow'})
        #
        #     # I, [2022-09-29T12:00:47.600052 #90508]  INFO -- : {"class":"String", "message":"You hear",
        #     # "details":{"dog":"wow","cats":{"chloe":"mow","timmy":"mow"}}}
        JSON = lambda do |klass, message, details = {}|
          ::JSON.generate(class: klass, message: message, details: details)
        end

        # - PRETTY_JSON - pretty json output
        #     notifier = LunaPark::Notifiers::Log.new(formatter: LunaPark::Notifiers::Log::Formatters::PRETTY_JSON)
        #     notifier.info('You hear', dog: 'wow', cat: {timmy:'purr'}, cow: 'moo', duck: 'quack', horse: 'yell')
        #
        #     # I, [2022-09-29T12:02:25.236301 #90508]  INFO -- : {
        #     #   "class": "String",
        #     #   "message": "You hear",
        #     #   "details": {
        #     #   "dog": "wow",
        #     #    "cat": {
        #     #      "timmy": "purr"
        #     #    },
        #     #    "cow": "moo",
        #     #    "duck": "quack",
        #     #    "horse": "yell"
        #     # }
        PRETTY_JSON = lambda do |klass, message, details = {}|
          ::JSON.pretty_generate(class: klass, message: message, details: details)
        end
      end
    end
  end
end
