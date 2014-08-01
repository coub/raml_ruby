require 'uri'
require 'uri_template'

module Raml
  class Root
    attr_accessor :children   , :title      , :version  , :base_uri     ,
                  :protocols  , :media_type , :schemas  , :documentation

    def initialize(root_data)
      @children = []
      @schemas  = {}

      root_data.each do |key, value|
        case key
        when /\A\//
          @children << Resource.new(key, value, self)

        when 'baseUriParameters'
          validate_base_uri_parameters value
          @children += value.map { |name, data| Parameter::BaseUriParameter.new name, data }

        when 'documentation'
          validate_documentation value
          @children += value.map { |doc| Documentation.new doc["title"], doc["content"] }

        when 'schemas'
          @schemas = validate_schemas value
          @schemas.merge(@schemas) { |k, val| Schema.new val }
          @children += @schemas.values

        when 'resourceTypes'
          validate_resource_types value
          @children += value.map { |h| h.map { |name, data| ResourceType.new name, data, self } }.flatten

        when 'traits'
          validate_traits value
          @children += value.map { |h| h.map { |name, data| Trait.new name, data, self } }.flatten

        else
          self.send("#{Raml.underscore(key)}=", value)
        end
      end

      validate
    end

    def document(verbose = false)
      doc = ''

      doc << "# #{title}\n"           if title
      doc << "Version: #{version}\n"  if version

      documents.each do |child|
        doc << child.document
      end
      
      base_uri_parameters.each do |child|
        doc << child.document
      end
      
      resources.each do |child|
        doc << child.document
      end

      puts doc if verbose
      
      doc
    end

    def documents
      @children.select{|child| child.is_a? Documentation}
    end

    def base_uri_parameters
      @children.select { |child| child.is_a? Parameter::BaseUriParameter }
    end
    
    def resources
      @children.select { |child| child.is_a? Resource }
    end

    def resource_types
      @children.select { |child| child.is_a? ResourceType }
    end

    def traits
      @children.select { |child| child.is_a? Trait }
    end
    
    private

    def validate
      validate_title            
      validate_base_uri
      validate_protocols
      validate_media_type
    end

    def validate_title
      if title.nil?
        raise RequiredPropertyMissing, 'Missing root title property.'
      else
        raise InvalidProperty, 'Root title property must be a string' unless title.is_a? String
      end
    end
    
    def validate_base_uri
      if base_uri.nil?
        raise RequiredPropertyMissing, 'Missing root baseUri property'
      else
        raise InvalidProperty, 'baseUri property must be a string' unless base_uri.is_a? String
      end
      
      # Check whether its a URL.
      uri = parse_uri base_uri
      
      # If the parser doesn't think its a URL or the URL is not for HTTP or HTTPS,
      # try to parse it as a URL template.
      if uri.nil? and not uri.kind_of? URI::HTTP
        template = parse_template
        
        # The template parser did not complain, but does it generate valid URLs?
        uri = template.expand Hash[ template.variables.map {|var| [ var, 'a'] } ]
        uri = parse_uri uri
        raise InvalidProperty, 'baseUri property is not a URL or a URL template.' unless
          uri and uri.kind_of? URI::HTTP
        
        raise RequiredPropertyMissing, 'version property is required when baseUri template has version parameter' if
          template.variables.include? 'version' and version.nil?
      end
    end
    
    def validate_protocols
      if protocols
        raise InvalidProperty, 'protocols property must be an array' unless
          protocols.is_a? Array
        
        raise InvalidProperty, 'protocols property must be an array strings' unless
          protocols.all? { |p| p.is_a? String }
        
        @protocols.map!(&:upcase)
        
        raise InvalidProperty, 'protocols property elements must be HTTP or HTTPS' unless 
          protocols.all? { |p| [ 'HTTP', 'HTTPS'].include? p }
      end
    end
    
    def validate_media_type
      if media_type
        raise InvalidProperty, 'mediaType property must be a string' unless media_type.is_a? String
        raise InvalidProperty, 'mediaType property is malformed'     unless media_type =~ Body::MEDIA_TYPE_RE
      end
    end
    
    def validate_schemas(schemas)
      raise InvalidProperty, 'schemas property must be an array'          unless 
        schemas.is_a? Array
      
      raise InvalidProperty, 'schemas property must be an array of maps'  unless
        schemas.all? {|s| s.is_a? Hash}
      
      raise InvalidProperty, 'schemas property must be an array of maps with string keys'   unless 
        schemas.all? {|s| s.keys.all?   {|k| k.is_a? String }}
      
      raise InvalidProperty, 'schemas property must be an array of maps with string values' unless 
        schemas.all? {|s| s.values.all? {|v| v.is_a? String }}
      
      raise InvalidProperty, 'schemas property contains duplicate schema names'             unless 
        schemas.map(&:keys).flatten.uniq!.nil?
        
      schemas.reduce({}) { |memo, schema| memo.merge! schema }
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
    
    def validate_documentation(documentation)
      raise InvalidProperty, 'documentation property must be an array' unless 
        documentation.is_a? Array
      
      raise InvalidProperty, 'documentation property must include at least one document or not be included' if 
        documentation.empty?
    end
    
    def validate_resource_types(types)
      raise InvalidProperty, 'resourceTypes property must be an array'          unless 
        types.is_a? Array
      
      raise InvalidProperty, 'resourceTypes property must be an array of maps'  unless
        types.all? {|s| s.is_a? Hash}
      
      raise InvalidProperty, 'resourceTypes property must be an array of maps with string keys'  unless 
        types.all? {|t| t.keys.all?   {|k| k.is_a? String }}
      
      raise InvalidProperty, 'resourceTypes property must be an array of maps with map values'   unless 
        types.all? {|t| t.values.all? {|v| v.is_a? Hash }}
      
      raise InvalidProperty, 'resourceTypes property contains duplicate type names'              unless 
        types.map(&:keys).flatten.uniq!.nil?
    end

    def validate_traits(traits)
      raise InvalidProperty, 'traits property must be an array'          unless 
        traits.is_a? Array
      
      raise InvalidProperty, 'traits property must be an array of maps'  unless
        traits.all? {|s| s.is_a? Hash}
      
      raise InvalidProperty, 'traits property must be an array of maps with string keys'  unless 
        traits.all? {|t| t.keys.all?   {|k| k.is_a? String }}
      
      raise InvalidProperty, 'traits property must be an array of maps with map values'   unless 
        traits.all? {|t| t.values.all? {|v| v.is_a? Hash }}
      
      raise InvalidProperty, 'traits property contains duplicate trait names'             unless 
        traits.map(&:keys).flatten.uniq!.nil?
    end

    def parse_uri(uri)
      URI.parse uri
    rescue URI::InvalidURIError
      nil
    end
    
    def parse_template
      URITemplate::RFC6570.new base_uri
    rescue URITemplate::RFC6570::Invalid
      raise InvalidProperty, 'baseUri property is not a URL or a URL template.'
    end
  end
end
