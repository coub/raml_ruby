module Raml
  class UnsupportedRamlVersion < StandardError; end
  class CantIncludeFile < StandardError; end
  
  # Abstract parameter
  class InvalidParameterType < StandardError; end
  class InapplicableParameterAttribute < StandardError; end
  class ParameterAttributeMustBeTrueOrFalse < StandardError; end

  # Root
  class RootTitleMissing < StandardError; end
  class RootBaseUriMissing < StandardError; end

  # Protocols
  class ProtocolMustBeArrayOfStrings < StandardError; end
  class ProtocolMustBeHTTPorHTTPS < StandardError; end
  
  # Body
  class FormParametersMissing < StandardError; end
  class FormCantHaveSchema < StandardError; end
end
