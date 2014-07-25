module Raml
  class Resource
    attr_accessor :children

    extend Common

    is_documentable

    def initialize(name, resource_data)
      @children = []
      @name = name

      resource_data.each do |key, value|
        if key.start_with?('/')
          @children << Resource.new(key, value)
        elsif Raml::Method::NAMES.include?(key)
          @children << Method.new(key, value)
        elsif key == "uriParameters"
          validate_uri_parameters value
          value.each do |name, uri_parameter_data|
            @children << Parameter::UriParameter.new(name, uri_parameter_data)
          end
        elsif key == "baseUriParameters"
          validate_base_uri_parameters value
          value.each do |name, uri_parameter_data|
            @children << Parameter::BaseUriParameter.new(name, uri_parameter_data)
          end
        else
          send("#{Raml.underscore(key)}=", value)
        end
      end
      
      validate
    end

    def document
      doc = ''
      doc << "**#{display_name || name}**\n"
      doc << "#{description}\n" if description
      doc << children.map(&:document).compact.join('\n')
      doc
    end

    def resources
      children.select { |child| child.is_a? Resource }
    end

    def methods
      children.select { |child| child.is_a? Method }
    end

    def uri_parameters
      children.select { |child| child.is_a? Parameter::UriParameter }
    end
    
    def base_uri_parameters
      children.select { |child| child.is_a? Parameter::BaseUriParameter }
    end
    
    private
    
    def validate
      raise InvalidProperty, 'description property mus be a string' unless description.nil? or description.is_a? String
    end
    
    def validate_uri_parameters(uri_parameters)
      raise InvalidProperty, 'uriParameters property must be a map' unless 
        uri_parameters.is_a? Hash
      
      raise InvalidProperty, 'uriParameters property must be a map with string keys' unless
        uri_parameters.keys.all?  {|k| k.is_a? String }

      raise InvalidProperty, 'uriParameters property must be a map with map values' unless
        uri_parameters.values.all?  {|v| v.is_a? Hash }      
    end
    
    def validate_base_uri_parameters(base_uri_parameters)
      raise InvalidProperty, 'baseUriParameters property must be a map' unless 
        base_uri_parameters.is_a? Hash
      
      raise InvalidProperty, 'baseUriParameters property must be a map with string keys' unless
        base_uri_parameters.keys.all?  {|k| k.is_a? String }

      raise InvalidProperty, 'baseUriParameters property must be a map with map values' unless
        base_uri_parameters.values.all?  {|v| v.is_a? Hash }
      
      raise InvalidProperty, 'baseUriParameters property can\'t contain reserved "version" parameter' if
        base_uri_parameters.include? 'version'
    end
  end
end
