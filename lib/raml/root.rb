require 'uri'
require 'uri_template'

module Raml
  class Root
    include Parent
    include Validation

    attr_accessor :title      , :version    , :base_uri     ,
                  :protocols  , :media_type , :documentation

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
          validate_schemas value
          @children += value.reduce({}) { |memo, map | memo.merge! map }.
                             map        { |name, data| Schema.new name, data }

        when 'resourceTypes'
          validate_resource_types value
          @children += value.reduce({}) { |memo, map | memo.merge! map }.
                             map        { |name, data| ResourceType.new name, data, self }

        when 'traits'
          validate_traits value
          @children += value.reduce({}) { |memo, map | memo.merge! map }.
                             map        { |name, data| Trait.new name, data, self }
        else
          begin
            send "#{Raml.underscore(key)}=", value
          rescue
            raise UnknownProperty, "#{key} is an unknown property."
          end
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

    children_of :documents, Documentation

    children_by :base_uri_parameters, :name, Parameter::BaseUriParameter    
    children_by :resources          , :name, Resource
    children_by :schemas            , :name, Schema
    children_by :traits             , :name, Trait
    children_by :resource_types     , :name, ResourceType

    def expand
      unless @expanded
        inline_reference SchemaReference      , schemas        , @children
        inline_reference TraitReference       , traits         , @children
        inline_reference ResourceTypeReference, resource_types , @children

        resource_types.values.each(&:apply_traits)
        resources.values.each(&:apply_traits)
        
        @expanded = true 
      end
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
        validate_string :title, title
      end
    end
    
    def validate_base_uri
      if base_uri.nil?
        raise RequiredPropertyMissing, 'Missing root baseUri property'
      else
        validate_string :base_uri, base_uri
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
        validate_array :protocols, protocols, String
        
        @protocols.map!(&:upcase)
        
        raise InvalidProperty, 'protocols property elements must be HTTP or HTTPS' unless 
          protocols.all? { |p| [ 'HTTP', 'HTTPS'].include? p }
      end
    end
    
    def validate_media_type
      if media_type
        validate_string :media_type, media_type
        raise InvalidProperty, 'mediaType property is malformed' unless media_type =~ Body::MEDIA_TYPE_RE
      end
    end
    
    def validate_schemas(schemas)
      validate_array :schemas, schemas, Hash
      
      raise InvalidProperty, 'schemas property must be an array of maps with string keys'   unless 
        schemas.all? {|s| s.keys.all?   {|k| k.is_a? String }}
      
      raise InvalidProperty, 'schemas property must be an array of maps with string values' unless 
        schemas.all? {|s| s.values.all? {|v| v.is_a? String }}
      
      raise InvalidProperty, 'schemas property contains duplicate schema names'             unless 
        schemas.map(&:keys).flatten.uniq!.nil?
    end
    
    def validate_base_uri_parameters(base_uri_parameters)
      validate_hash :base_uri_parameters, base_uri_parameters, String, Hash
      
      raise InvalidProperty, 'baseUriParameters property can\'t contain reserved "version" parameter' if
        base_uri_parameters.include? 'version'
    end
    
    def validate_documentation(documentation)
      validate_array :documentation, documentation
      
      raise InvalidProperty, 'documentation property must include at least one document or not be included' if 
        documentation.empty?
    end
    
    def validate_resource_types(types)
      validate_array :resource_types, types, Hash
      
      raise InvalidProperty, 'resourceTypes property must be an array of maps with string keys'  unless 
        types.all? {|t| t.keys.all?   {|k| k.is_a? String }}
      
      raise InvalidProperty, 'resourceTypes property must be an array of maps with map values'   unless 
        types.all? {|t| t.values.all? {|v| v.is_a? Hash }}
      
      raise InvalidProperty, 'resourceTypes property contains duplicate type names'              unless 
        types.map(&:keys).flatten.uniq!.nil?
    end

    def validate_traits(traits)
      validate_array :traits, traits, Hash
      
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

    def inline_reference(reference_type, map, nodes)
      nodes.map! do |node|
        if node.is_a? reference_type
          map[node.name]
        else
          inline_reference reference_type, map, node.children if node.respond_to? :children
          node
        end
      end
    end
  end
end
