require 'thor'

module LunaPark
  module CLI
    class App < Thor
      desc 'version', 'show current version'
      def version
        say VERSION
      end

      desc 'generate PATTERN:TYPE PATH/TO/CLASS OPTIONS',
           'Generate new classes in your project, for detailed information see "lunapark help generate"'
      long_desc <<-LONGDESC.gsub("\n", "\05").gsub(" ", "\0 ")
Generator will help you generate some new classes for your app.
If your want to create form which help you update account, run:

> lunapark g form:simple app/accounts/update

Which:
  - form           - Type of pattern
  - simple         - Pattern option (for all opinions see: lunapark generate help)
  - path/to/class  - Path witch class should be created
      LONGDESC

      subcommand 'generate', Generate
    end
  end
end