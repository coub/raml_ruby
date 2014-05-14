module Raml
  class Body
    extend Common
    is_documentable

    attr_accessor :media_type
    attr_accessor :schema, :example

    def initialize(media_type, body_data)
      @media_type = media_type

      body_data.each do |key, value|
        send("#{Raml.underscore(key)}=", value)
      end
    end

    def document
      lines = []
      lines << "**%s**:" % @media_type
      lines << "schema path: %s" % @schema if @schema
      lines << "Example:  \n\n%s" % Raml.code_indenter(@example) if @example

      lines.join "  \n"
    end
  end
end
