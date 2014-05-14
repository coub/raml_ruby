module Raml
  class Body
    extend Common
    is_documentable

    attr_accessor :schema, :example

    def initialize(name, body_data)
      @name = name

      body_data.each do |key, value|
        send("#{Raml.underscore(key)}=", value)
      end
    end
  end
end
