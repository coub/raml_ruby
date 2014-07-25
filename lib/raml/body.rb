module Raml
  class Body
    MEDIA_TYPE_RE = %r{[a-z\d][-\w.+!#$&^]{0,63}/[a-z\d][-\w.+!#$&^]{0,63}(;.*)?}oi
    
    extend Common
    is_documentable
    
    attr_accessor :children
    attr_accessor :media_type
    attr_accessor :schema, :example

    def initialize(media_type, body_data)
      @children = []
      @media_type = media_type

      body_data.each do |key, value|
        if key == "formParameters"
          value.each do |name, form_parameter_data|
            @children << Parameter::FormParameter.new(name, form_parameter_data)
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
        raise FormCantHaveSchema    if @schema
        raise FormParametersMissing if form_parameters.empty?
      end
    end
  end
end
