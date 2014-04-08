module Raml
  class Response < Node
    attr_accessor :body, :headers

    def initialize(response_data)
      response_data.each do |key, value|
        case key
        when 'body'
          self.body = Body.new(value)
        when 'headers'
          self.headers ||= {}

          header_list = value
          header_list.each do |name, attributes|
            headers[name] = Header.new(attributes)
          end
        else
          send("#{underscore(key)}=", value)
        end
      end

    end
  end
end
