module Raml
  class Method
    NAMES = %w(options get head post put delete trace connect patch)

    extend Common

    is_documentable

    attr_accessor :children, :protocols

    def initialize(name, method_data)
      @children = []
      @name = name
            
      method_data.each do |key, value|
        case key
        when 'headers'
          validate_headers value
          value.each do |name, header_data|
            @children << Header.new(name, header_data)
          end
        when 'queryParameters'
          validate_query_parameters value
          value.each do |name, query_parameter_data|
            @children << Parameter::QueryParameter.new(name, query_parameter_data)
          end
        when 'body'
          validate_body value
          value.each do |name, body_data|
            @children << Body.new(name, body_data)
          end
        when 'responses'
          validate_responses value
          value.each do |name, response_data|
            @children << Response.new(name, response_data)
          end
        else
          send("#{Raml.underscore(key)}=", value)
        end
      end

      validate
      set_defaults
    end
    
    def set_defaults
      self.protocols ||= []
    end

    def document
      lines = []
      lines << "####{}**#{@display_name || @name}**"
      lines << "#{@description}"

      lines << "Supported HTTP protocols: %s" % protocols.join(', ')

      if headers.any?
        lines << "**Headers:**"
        headers.each do |header|
          lines << header.document
        end
      end

      if query_parameters.any?
        lines << "**Query Parameters:**"
        query_parameters.each do |query_parameter|
          lines << query_parameter.document
        end
      end

      if bodies.any?
        lines << "**Body:**"
        bodies.each do |body|
          lines << body.document
        end
      end

      if responses.any?
        lines << "**Responses:**"
        responses.each do |response|
          lines << response.document
        end
      end

      lines.join "  \n"
    end

    def headers
      children.select { |child| child.is_a? Header }
    end

    def query_parameters
      children.select { |child| child.is_a? Parameter::QueryParameter }
    end

    def bodies
      children.select { |child| child.is_a? Body }
    end

    def responses
      children.select { |child| child.is_a? Response }
    end

    private
    
    def validate
      raise InvalidMethod, "#{@name} is an unsupported HTTP method" unless NAMES.include? @name
      raise InvalidProperty, 'description property mus be a string' unless description.nil? or description.is_a? String
      
      validate_protocols
    end
    
    def validate_headers(headers)
      raise InvalidProperty, 'headers property must be a map' unless 
        headers.is_a? Hash
      
      raise InvalidProperty, 'headers property must be a map with string keys' unless
        headers.keys.all?  {|k| k.is_a? String }

      raise InvalidProperty, 'headers property must be a map with map values' unless
        headers.values.all?  {|v| v.is_a? Hash }      
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
    
    def validate_query_parameters(query_parameters)
      raise InvalidProperty, 'queryParameters property must be a map' unless 
        query_parameters.is_a? Hash
      
      raise InvalidProperty, 'queryParameters property must be a map with string keys' unless
        query_parameters.keys.all?  {|k| k.is_a? String }

      raise InvalidProperty, 'queryParameters property must be a map with map values' unless
        query_parameters.values.all?  {|v| v.is_a? Hash }      
    end

    def validate_body(body)
      raise InvalidProperty, 'body property must be a map' unless
        body.is_a? Hash
        
      raise InvalidProperty, 'body property must be a map with string keys' unless
        body.keys.all?  {|k| k.is_a? String }

      raise InvalidProperty, 'body property must be a map with map values' unless
        body.values.all?  {|v| v.is_a? Hash }
    end

    def validate_responses(responses)
      raise InvalidProperty, 'responses property must be a map' unless 
        responses.is_a? Hash
      
      raise InvalidProperty, 'responses property must be a map with integer keys' unless
        responses.keys.all?  {|k| k.is_a? Integer }

      raise InvalidProperty, 'responses property must be a map with map values' unless
        responses.values.all?  {|v| v.is_a? Hash }      
    end
  end
end
