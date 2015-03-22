class Raml::AbstractResource < Raml::PropertiesNode
  # @!attribute [r] type
  #   @return [Raml::ResourceType, Raml::ResourceTypeReference>] the resource type or resource type references, if any.
  child_of :type, [ Raml::ResourceType, Raml::ResourceTypeReference ]
end
