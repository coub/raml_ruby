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
  end
end
