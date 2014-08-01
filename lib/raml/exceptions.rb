module Raml
  class RamlError < StandardError; end
  
  class UnsupportedRamlVersion          < RamlError; end
  class CantIncludeFile                 < RamlError; end
  
  # Properties
  class RequiredPropertyMissing         < RamlError; end
  class InvalidProperty                 < RamlError; end
  
  class InvalidSchema                   < RamlError; end

  # Methods
  class InvalidMethod                   < RamlError; end

  # Parameters
  class InvalidParameterType            < RamlError; end
  class InapplicableParameterAttribute  < RamlError; end
  class InvalidParameterAttribute       < RamlError; end
  
  # Body
  class InvalidMediaType                < RamlError; end

  # ResourceType
  class InvalidResourceType             < RamlError; end
end
