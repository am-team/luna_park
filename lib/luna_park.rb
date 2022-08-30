# frozen_string_literal: true

# add description
module LunaPark
  module Entities;   end
  module Errors;     end
  module Extensions; end
  module Forms; end
  module Handlers; end
  module Http; end
  module UseCases; end
  module Notifiers; end
  module Serializers; end
  module Tools; end
  module UseCases; end
  module Validators; end
  module Values; end
end

require 'luna_park/tools'
require 'luna_park/errors'
require 'luna_park/errors/base'
require 'luna_park/errors/system'
require 'luna_park/errors/business'
require 'luna_park/errors/json_parse'
LunaPark::Tools.if_gem_installed('rest-client', '~> 2.1') { require 'luna_park/errors/http' }
require 'luna_park/extensions/attributable'
require 'luna_park/extensions/wrappable'
require 'luna_park/extensions/callable'
require 'luna_park/extensions/serializable'
require 'luna_park/extensions/comparable_debug'
require 'luna_park/extensions/comparable'
require 'luna_park/extensions/validatable'
require 'luna_park/extensions/predicate_attr_accessor'
require 'luna_park/extensions/typed_attr_accessor'
require 'luna_park/extensions/dsl/attributes'
require 'luna_park/extensions/dsl/foreign_key'
require 'luna_park/extensions/data_mapper'
require 'luna_park/extensions/has_errors'
require 'luna_park/extensions/injector'
require 'luna_park/extensions/repositories/postgres/create'
require 'luna_park/extensions/repositories/postgres/read'
require 'luna_park/extensions/repositories/postgres/update'
require 'luna_park/extensions/repositories/postgres/delete'
LunaPark::Tools.if_gem_installed('dry-validation', '~> 1.1') { require 'luna_park/extensions/validatable/dry' }
require 'luna_park/entities/simple'
require 'luna_park/entities/attributable'
require 'luna_park/entities/nested'
require 'luna_park/forms/simple'
require 'luna_park/forms/single_item'

LunaPark::Tools.if_gem_installed('rest-client', '~> 2.1') { require 'luna_park/http/client' }
LunaPark::Tools.if_gem_installed('bugsnag', '~> 6') { require 'luna_park/notifiers/bugsnag' }
LunaPark::Tools.if_gem_installed('sentry-ruby', '>= 4') { require 'luna_park/notifiers/sentry' }

require 'luna_park/notifiers/log'

require 'luna_park/handlers/simple'
require 'luna_park/use_cases/scenario'
require 'luna_park/use_cases/service'
require 'luna_park/serializers/simple'
require 'luna_park/callable'

LunaPark::Tools.if_gem_installed('dry-validation', '~> 1.1') { require 'luna_park/validators/dry' }

require 'luna_park/values/compound'
require 'luna_park/values/single'
require 'luna_park/values/attributable'
require 'luna_park/mappers/simple'
require 'luna_park/mappers/codirectional'
require 'luna_park/repository'
require 'luna_park/repositories/sequel'
require 'luna_park/repositories/postgres'
