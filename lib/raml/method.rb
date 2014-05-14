module Raml
  class Method
    NAMES = %w(options get head post put delete trace connect)

    attr_accessor :headers, :protocols, :query_parameters, :body, :responses

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

    end

  end
end
