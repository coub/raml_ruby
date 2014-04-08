module Raml
  class Method < Node
    NAMES = %w(options get head post put delete trace connect)

    attr_accessor :headers, :protocols, :query_parameters, :body, :responses

    def initialize(method_data)
      method_data.each do |key, value|
        case key
        when 'headers'
          self.headers ||= {}

          header_list = value
          header_list.each do |name, attributes|
            headers[name] = Header.new(attributes)
          end
        when 'protocols'
          puts "PROTOCOLS are not implemented"
          # self.protocols ||= {}

          # protocol_list = value
          # protocol_list.each do |name, attributes|
          #   protocols[name] = Protocol.new(attributes)
          # end
        when 'queryParameters'
          self.query_parameters ||= {}

          query_parameter_list = value
          query_parameter_list.each do |name, attributes|
            query_parameters[name] = Parameter::QueryParameter.new(attributes)
          end
        when 'body'
          self.body = Body.new(value)
        when 'responses'
          self.responses ||= {}

          response_list = value
          response_list.each do |name, attributes|
            responses[name] = Response.new(attributes)
          end
        else
          send("#{underscore(key)}=", value)
        end
      end

    end

  end
end
