module Raml
  class RamlError < StandardError; end
  
  class UnsupportedRamlVersion          < RamlError; end
  class CantIncludeFile                 < RamlError; end
  
  class RequiredPropertyMissing         < RamlError; end
  class InvalidProperty                 < RamlError; end
  class UnknownProperty                 < RamlError; end
  
  class InvalidParent                   < RamlError; end
  class InvalidSchema                   < RamlError; end

  class InvalidMethod                   < RamlError; end

  class InvalidParameterType            < RamlError; end
  class InapplicableParameterAttribute  < RamlError; end
  class InvalidParameterAttribute       < RamlError; end
  
  class InvalidMediaType                < RamlError; end

  class UnknownTraitReference           < RamlError; end
  class UnknownResourceTypeReference    < RamlError; end
  class UnknownSecuritySchemeReference  < RamlError; end
  class MergeError                      < RamlError; end
  class UnknownTypeOrTraitParameter     < RamlError; end
  class UnknownTypeOrTraitParamFunction < RamlError; end
end
