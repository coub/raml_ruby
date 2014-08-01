module Raml
  class Body
    MEDIA_TYPE_RE = %r{[a-z\d][-\w.+!#$&^]{0,63}/[a-z\d][-\w.+!#$&^]{0,63}(;.*)?}oi
    
    extend Common
    is_documentable
    
    attr_accessor :children, :media_type, :schema, :example

    def initialize(media_type, body_data, root)
      @children = []
      @media_type = media_type

      body_data.each do |key, value|
        case key
        when 'formParameters'
          validate_form_parameters value
          value.each do |name, form_parameter_data|
            @children << Parameter::FormParameter.new(name, form_parameter_data)
          end

        when 'schema'
          validate_schema value
          if root.schemas.include? value
            @schema = SchemaReference.new value
          else
            @schema = Schema.new value
          end

        else
          send("#{Raml.underscore(key)}=", value)
        end
      end
      
      validate
    end
    
    def document
      lines = []
      lines << "**%s**:" % @media_type
      lines << "schema path: %s" % @schema if @schema
      lines << "Example:  \n\n%s" % Raml.code_indenter(@example) if @example

      lines.join "  \n"
    end
    
    def form_parameters
      @children.select { |child| child.is_a? Parameter::FormParameter }
    end
    
    def web_form?
      [ 'application/x-www-form-urlencoded', 'multipart/form-data' ].include? @media_type
    end
    
    private
    
    def validate
      raise InvalidMediaType, 'body media type is invalid' unless media_type =~ Body::MEDIA_TYPE_RE
      
      if web_form?
        raise InvalidProperty, 'schema property can\'t be defined for web forms.' if schema
        raise RequiredPropertyMissing, 'formParameters property must be specified for web forms.' if
          form_parameters.empty?
      end
    end
    
    def validate_form_parameters(form_parameters)
      raise InvalidProperty, 'formParameters property must be a map' unless 
        form_parameters.is_a? Hash
      
      raise InvalidProperty, 'formParameters property must be a map with string keys' unless
        form_parameters.keys.all?  {|k| k.is_a? String }

      raise InvalidProperty, 'formParameters property must be a map with map values' unless
        form_parameters.values.all?  {|v| v.is_a? Hash }      
    end

    def validate_schema(schema)
      raise InvalidProperty, 'schema property must be a string.'           unless schema.is_a? String
      raise InvalidProperty, 'schema property must be a non-empty string.' if     schema.empty?
    end
  end
end
