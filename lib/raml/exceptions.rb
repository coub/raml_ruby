module Raml
  class RamlError < StandardError; end
  
  class UnsupportedRamlVersion          < RamlError; end
  class CantIncludeFile                 < RamlError; end
  
  # Properties
  class RequiredPropertyMissing         < RamlError; end
  class InvalidProperty                 < RamlError; end
  class UnknownProperty                 < RamlError; end
  
  class InvalidParent                   < RamlError; end
  class InvalidSchema                   < RamlError; end

  # Methods
  class InvalidMethod                   < RamlError; end

  # Parameters
  class InvalidParameterType            < RamlError; end
  class InapplicableParameterAttribute  < RamlError; end
  class InvalidParameterAttribute       < RamlError; end
  
  # Body
  class InvalidMediaType                < RamlError; end

  class UnknownTraitReference           < RamlError; end
  class UnknownResourceTypeReference    < RamlError; end
  class MergeError                      < RamlError; end
  class UnknownTypeOrTraitParameter     < RamlError; end
  class UnknownTypeOrTraitParamFunction < RamlError; end
end
