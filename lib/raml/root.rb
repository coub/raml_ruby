require 'uri'
require 'uri_template'

module Raml
  class Root
    attr_accessor :children
    attr_accessor :title, :version, :base_uri, :base_uri_parameters,
      :protocols, :media_type, :schemas, :base_uri_parameters, :documentation, :resources

    def initialize(root_data)
      @children = []

      root_data.each do |key, value|
        if key.start_with?('/')
          @children << Resource.new(key, value)
        elsif key == 'documentation'
          value.each do |document|
            @children << Documentation.new(document["title"], document["content"])
          end
        else
          self.send("#{Raml.underscore(key)}=", value)
        end
      end

      validate
    end

    def document(verbose = false)
      result = ""
      lines = []

      lines << "# #{title}" if title
      lines << "Version: #{version}" if version

      @children.each do |child|
        lines << child.document
      end

      result = lines.join "\n"

      puts result if verbose
      result
    end

    def documents
      @children.select{|child| child.is_a? Documentation}
    end

    private

    def validate
      validate_title            
      validate_base_uri
      validate_protocols
      validate_media_type
      validate_schemas
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
    
    MEDIA_TYPE_RE = %r{[a-z\d][-\w.+!#$&^]{0,63}/[a-z\d][-\w.+!#$&^]{0,63}(;.*)?}oi
    
    def validate_media_type
      if media_type
        raise InvalidProperty, 'mediaType property must be a string' unless media_type.is_a? String
        raise InvalidProperty, 'mediaType property is malformed'     unless media_type =~ MEDIA_TYPE_RE
      end
    end
    
    def validate_schemas
      if schemas
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
        
        self.schemas = schemas.reduce({}) { |memo, schema| memo.merge! schema }
      else
        self.schemas = {}
      end
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
