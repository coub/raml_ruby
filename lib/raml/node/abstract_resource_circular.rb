class Raml::AbstractResource < Raml::PropertiesNode
  child_of :type, [ Raml::ResourceType, Raml::ResourceTypeReference ]
end
