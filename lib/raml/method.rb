module Raml
  class Method
    NAMES = %w(options get head post put delete trace connect)

    extend Common

    is_documentable

    attr_accessor :children

    def initialize(name, method_data)
      @children = []
      @name = name

      method_data.each do |key, value|
        case key
        when 'headers'
          value.each do |name, header_data|
            @children << Header.new(name, header_data)
          end
        when 'protocols'
          @children << Protocol.new(value)
        when 'queryParameters'
          value.each do |name, query_parameter_data|
            @children <<  Parameter::QueryParameter.new(name, query_parameter_data)
          end
        when 'body'
          value.each do |name, body_data|
            @children << Body.new(name, body_data)
          end
        when 'responses'
          value.each do |name, response_data|
            @children << Response.new(name, response_data)
          end
        else
          send("#{Raml.underscore(key)}=", value)
        end
      end

      set_default_protocol
    end

    def set_default_protocol
      #TODO
    end

    def document
      lines = []
      lines << "**#{@display_name || @name}**"
      lines << "#{@description}"

      if protocol
        supported_protocols = []
        supported_protocols << "HTTP" if protocol.http?
        supported_protocols << "HTTPS" if protocol.https?
        lines << "Supported HTTP protocols: %s" % supported_protocols
      end

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


    def protocol
      @children.select {|child| child.is_a? Protocol}.first
    end

    def headers
      @children.select {|child| child.is_a? Header}
    end

    def query_parameters
      @children.select {|child| child.is_a? Parameter::QueryParameter}
    end

    def bodies
      @children.select {|child| child.is_a? Body}
    end

    def responses
      @children.select {|child| child.is_a? Response}
    end

  end
end
