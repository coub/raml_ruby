module Raml
  class RamlError < StandardError; end
  
  class UnsupportedRamlVersion          < RamlError; end
  class CantIncludeFile                 < RamlError; end
    
  # Abstract parameter
  class InvalidParameterType            < RamlError; end
  class InapplicableParameterAttribute  < RamlError; end
  class InvalidParameterAttribute       < RamlError; end

  # Root
  class RootTitleMissing                < RamlError; end
  class RootBaseUriMissing              < RamlError; end

  # Protocols
  class ProtocolMustBeArrayOfStrings    < RamlError; end
  class ProtocolMustBeHTTPorHTTPS       < RamlError; end
  
  # Body
  class FormParametersMissing           < RamlError; end
  class FormCantHaveSchema              < RamlError; end
end
