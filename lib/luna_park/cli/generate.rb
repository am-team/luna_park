require 'luna_park/cli/generators'
require 'thor'

module LunaPark
  module CLI
    class Generate < Thor
      register(Generators::Forms::Simple, 'form:simple', 'form:simple', 'For form which does not have a lot of inputs')
      register(Generators::Forms::Single, 'form:single', 'form:single', 'For single objects forms')
      map 'form' => 'form:simple'
    end
  end
end