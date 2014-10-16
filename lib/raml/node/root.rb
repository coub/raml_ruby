require 'uri'
require 'uri_template'

module Raml
  # RAML root node.  Its parent is itself.
  class Root < PropertiesNode
    inherit_class_attributes

    include Parent
    include Validation

    # @!attribute [rw] title
    #   @return [String] API title.

    # @!attribute [rw] version
    #   @return [String,nil] API version.

    # @!attribute [rw] base_uri
    #   @return [String] the API base URI.

    # @!attribute [rw] protocols
    #   @return [Array<String>, nil] the supported protocols. Nil or an array of up to two string
    #     elements from the set "HTTP" and "HTTPS".

    # @!attribute [rw] media_type
    #   @return [String] the default request and response body media type.

    # @!attribute [r] documents
    #   @return [Array<Raml::Documentation>] the top level documentation.

    # @!attribute [r] base_uri_parameters
    #   @return [Hash<String, Raml::Parameter::BaseUriParameter>] the base URI parameters, keyed
    #     by the parameter name.

    # @!attribute [r] schemas
    #   @return [Hash<String, Raml::Schema>] the schema definitions, keyed by the schema name.

    # @!attribute [r] resources
    #   @return [Hash<String, Raml::Resource>] the nested resources, keyed by the resource relative path.

    # @!attribute [r] traits
    #   @return [Hash<String, Raml::Trait>] the trait definitions, keyed by the trait name.

    # @!attribute [r] resource_types
    #   @return [Hash<String, Raml::ResourceType>] the resource type definitions, keyed by the resource type name.

    scalar_property :title      , :version    , :base_uri     ,
                    :protocols  , :media_type

    non_scalar_property :base_uri_parameters, :documentation , :schemas,  :secured_by,
                        :security_schemes   , :resource_types, :traits

    regexp_property( /\A\//, ->(key,value) { Resource.new key, value, self } )

    children_of :documents, Documentation

    children_by :base_uri_parameters, :name, Parameter::BaseUriParameter
    children_by :resources          , :name, Resource
    children_by :schemas            , :name, Schema
    children_by :traits             , :name, Trait
    children_by :resource_types     , :name, ResourceType

    alias :default_media_type         :media_type
    alias :trait_declarations         :traits
    alias :resource_type_declarations :resource_types
    alias :schema_declarations        :schemas

    def initialize(root_data)
      super nil, root_data, self
    end

    # Applies resource types and traits, and inlines schemas.  It should be called
    # before documentation is generated.
    def expand
      unless @expanded
        resources.values.each(&:apply_resource_type)
        resources.values.each(&:apply_traits)
        inline_reference SchemaReference, schemas, @children
        @expanded = true
      end
    end

    # @private
    def resource_path
      ''
    end

    private

    def validate
      raise RequiredPropertyMissing, 'Missing root title property.'  if title.nil?
      raise RequiredPropertyMissing, 'Missing root baseUri property' if base_uri.nil?
      _validate_base_uri
    end

    def validate_title
      validate_string :title, title
    end

    def _validate_base_uri
      validate_string :base_uri, base_uri

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

    def parse_schemas(schemas)
      validate_array :schemas, schemas, Hash

      raise InvalidProperty, 'schemas property must be an array of maps with string keys'   unless
        schemas.all? {|s| s.keys.all?   {|k| k.is_a? String }}

      raise InvalidProperty, 'schemas property must be an array of maps with string values' unless
        schemas.all? {|s| s.values.all? {|v| v.is_a? String }}

      raise InvalidProperty, 'schemas property contains duplicate schema names'             unless
        schemas.map(&:keys).flatten.uniq!.nil?

      schemas.reduce({}) { |memo, map | memo.merge! map }.
              map        { |name, data| Schema.new name, data, self }
    end

    def parse_base_uri_parameters(base_uri_parameters)
      validate_hash :base_uri_parameters, base_uri_parameters, String, Hash

      raise InvalidProperty, 'baseUriParameters property can\'t contain reserved "version" parameter' if
        base_uri_parameters.include? 'version'

      base_uri_parameters.map { |name, data| Parameter::BaseUriParameter.new name, data, self }
    end

    def parse_documentation(documentation)
      validate_array :documentation, documentation

      raise InvalidProperty, 'documentation property must include at least one document or not be included' if
        documentation.empty?

      documentation.map { |doc| doc = doc.dup; Documentation.new doc.delete("title"), doc, self }
    end

    def parse_secured_by(data)
      # XXX ignored for now
    end

    def parse_security_schemes(data)
      # XXX ignored for now
    end

    def parse_resource_types(types)
      validate_array :resource_types, types, Hash

      raise InvalidProperty, 'resourceTypes property must be an array of maps with string keys'  unless
        types.all? {|t| t.keys.all?   {|k| k.is_a? String }}

      raise InvalidProperty, 'resourceTypes property must be an array of maps with map values'   unless
        types.all? {|t| t.values.all? {|v| v.is_a? Hash }}

      raise InvalidProperty, 'resourceTypes property contains duplicate type names'              unless
        types.map(&:keys).flatten.uniq!.nil?

      types.reduce({}) { |memo, map | memo.merge! map }.
            map        { |name, data| ResourceType.new name, data, self }
    end

    def parse_traits(traits)
      validate_array :traits, traits, Hash

      raise InvalidProperty, 'traits property must be an array of maps with string keys'  unless
        traits.all? {|t| t.keys.all?   {|k| k.is_a? String }}

      raise InvalidProperty, 'traits property must be an array of maps with map values'   unless
        traits.all? {|t| t.values.all? {|v| v.is_a? Hash }}

      raise InvalidProperty, 'traits property contains duplicate trait names'             unless
        traits.map(&:keys).flatten.uniq!.nil?

      traits.reduce({}) { |memo, map | memo.merge! map }.
             map        { |name, data| Trait.new name, data, self }
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
