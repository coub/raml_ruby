module Raml
  class RamlError < StandardError; end
  
  class UnsupportedRamlVersion          < RamlError; end
  class CantIncludeFile                 < RamlError; end
  
  # Properties
  class RequiredPropertyMissing         < RamlError; end
  class InvalidProperty                 < RamlError; end
  
  # Methods
  class InvalidMethod                   < RamlError; end
  
  # Abstract parameter
  class InvalidParameterType            < RamlError; end
  class InapplicableParameterAttribute  < RamlError; end
  class InvalidParameterAttribute       < RamlError; end

  # Protocols
  class ProtocolMustBeArrayOfStrings    < RamlError; end
  class ProtocolMustBeHTTPorHTTPS       < RamlError; end
  
  # Body
  class FormParametersMissing           < RamlError; end
  class FormCantHaveSchema              < RamlError; end
end
