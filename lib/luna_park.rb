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

require_relative 'luna_park/extensions/exceptions/substitutive'
require_relative 'luna_park/errors'
require_relative 'luna_park/extensions/attributable'
require_relative 'luna_park/extensions/wrappable'
require_relative 'luna_park/extensions/callable'
require_relative 'luna_park/extensions/serializable'
require_relative 'luna_park/extensions/comparable_debug'
require_relative 'luna_park/extensions/comparable'
require_relative 'luna_park/extensions/validatable'
require_relative 'luna_park/extensions/predicate_attr_accessor'
require_relative 'luna_park/extensions/typed_attr_accessor'
require_relative 'luna_park/extensions/dsl/attributes'
require_relative 'luna_park/extensions/dsl/foreign_key'
require_relative 'luna_park/extensions/data_mapper'
require_relative 'luna_park/entities/simple'
require_relative 'luna_park/entities/attributable'
require_relative 'luna_park/entities/nested'
require_relative 'luna_park/forms/simple'
require_relative 'luna_park/forms/single_item'

if defined?(::RestClient) && defined?(::Bugsnag)
  require_relative 'luna_park/gateways/http/errors/rest_bugsnag'
  require_relative 'luna_park/gateways/http/handlers/rest_bugsnag'
end

if defined?(::RestClient)
  require_relative 'luna_park/gateways/http/errors/rest'
  require_relative 'luna_park/gateways/http/handlers/rest'
  require_relative 'luna_park/gateways/http/rest_client'
end

require_relative 'luna_park/gateways/http/requests/base'
require_relative 'luna_park/gateways/http/requests/json'

require_relative 'luna_park/handlers/simple'
require_relative 'luna_park/interactors/sequence'
require_relative 'luna_park/serializers/simple'
require_relative 'luna_park/callable'

if defined?(::Dry::Validation)
  require_relative 'luna_park/validators/dry'
  require_relative 'luna_park/extensions/validatable/dry'
end

require_relative 'luna_park/values/compound'
require_relative 'luna_park/values/single'
require_relative 'luna_park/values/attributable'
require_relative 'luna_park/mappers/simple'
require_relative 'luna_park/repositories/sequel'
