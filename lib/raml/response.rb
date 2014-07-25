module Raml
  class Response
    extend Common

    is_documentable

    attr_accessor :children

    def initialize(name, response_data)
      @children = []
      @name = name

      response_data.each do |key, value|
        case key
        when 'body'
          validate_body value
          value.each do |name, body_data|
            @children << Body.new(name, body_data)
          end
        when 'headers'
          value.each do |name, header_data|
            @children << Header.new(name, header_data)
          end
        else
          send("#{Raml.underscore(key)}=", value)
        end
      end
    end

    def document
      lines = []

      lines << "**%s**" % (@display_name || @name)
      lines << @description.to_s

      if bodies.any?
        lines << "**Body:**"
        bodies.each do |body|
          lines << body.document
        end
      end

      if headers.any?
        lines << "**Headers:**"
        headers.each do |header|
          lines << header.document
        end
      end

      lines.join "\n\n"
    end

    def bodies
      @children.select {|child| child.is_a? Body}
    end

    def headers
      @children.select {|child| child.is_a? Header}
    end
    
    private
    def validate_body(body)
      raise InvalidProperty, 'body property must be a map' unless
        body.is_a? Hash
        
      raise InvalidProperty, 'body property must be a map with string keys' unless
        body.keys.all?  {|k| k.is_a? String }

      raise InvalidProperty, 'body property must be a map with map values' unless
        body.values.all?  {|v| v.is_a? Hash }
    end
  end
end
