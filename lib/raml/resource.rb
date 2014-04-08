module Raml
  class Resource < Node
    attr_accessor :resources, :methods
    attr_accessor :uri_parameters

    def initialize(resource_data)
      resource_data.each do |key, value|
        if key.start_with?('/')
          self.resources ||= {}
          self.resources[key] = Resource.new(value)
        elsif Raml::Method::NAMES.include?(key)
          self.methods ||= {}
          self.methods[key] = Method.new(value)
        elsif key == "uriParameters"
          self.uri_parameters ||= {}

          uri_parameter_list = value
          uri_parameter_list.each do |name, attributes|
            uri_parameters[name] = Parameter::UriParameter.new(attributes)
          end
        else
          send("#{underscore(key)}=", value)
        end
      end
    end


  end
end
