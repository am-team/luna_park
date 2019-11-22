# frozen_string_literal: true

# add description
module LunaPark
  module Entities;   end
  module Errors;     end
  module Extensions; end
  module Forms; end
  module Handlers; end
  module Interactors; end
  module Serializers; end
  module UseCases; end
  module Validators; end
  module Values; end
end

require 'luna_park/extensions/exceptions/substitutive'
require 'luna_park/errors'
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
require 'luna_park/extensions/repositories/postgres/create'
require 'luna_park/extensions/repositories/postgres/read'
require 'luna_park/extensions/repositories/postgres/update'
require 'luna_park/extensions/repositories/postgres/delete'
require 'luna_park/entities/simple'
require 'luna_park/entities/attributable'
require 'luna_park/entities/nested'
require 'luna_park/forms/simple'
require 'luna_park/forms/single_item'

require 'luna_park/gateways/http/requests/base'
require 'luna_park/gateways/http/requests/json'

require 'luna_park/gateways/http/errors/default'
require 'luna_park/gateways/http/handlers/default'

if defined?(::Bugsnag)
  require 'luna_park/gateways/http/errors/bugsnag'
  require 'luna_park/gateways/http/handlers/bugsnag'
end

require 'luna_park/gateways/http/rest_client' if defined?(::RestClient)

require 'luna_park/handlers/simple'
require 'luna_park/interactors/sequence'
require 'luna_park/serializers/simple'
require 'luna_park/callable'

if defined?(::Dry::Validation)
  require 'luna_park/validators/dry'
  require 'luna_park/extensions/validatable/dry'
end

require 'luna_park/values/compound'
require 'luna_park/values/single'
require 'luna_park/values/attributable'
require 'luna_park/mappers/simple'
require 'luna_park/repository'
require 'luna_park/repositories/sequel'
