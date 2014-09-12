module Raml
  class Response < PropertiesNode
    inherit_class_attributes

    include Documentable
    include Global
    include Merge
    include Parent
    include Validation

    non_scalar_property :body, :headers

    children_by :bodies , :media_type, Body
    children_by :headers, :name      , Header

    def initialize(name, properties, parent)
      super
      @name = name.to_i
    end

    def document
      lines = []

      lines << "**%s**" % (@display_name || @name)
      lines << @description.to_s

      if bodies.any?
        lines << "**Body:**"
        bodies.values.each do |body|
          lines << body.document
        end
      end

      if headers.any?
        lines << "**Headers:**"
        headers.values.each do |header|
          lines << header.document
        end
      end

      lines.join "\n\n"
    end

    def merge(other)
      raise MergeError, "Response status codes don't match." if name != other.name

      super

      merge_properties other, :headers
      merge_properties other, :bodies

      self
    end

    private

    def parse_body(value)
      if value.is_a? Hash and value.keys.all? {|k| k.is_a? String and k =~ /.+\/.+/ }
        # If all keys looks like media types, its not a default media type body.
        validate_hash 'body', value, String, Hash
        value.map { |b_name, b_data| Body.new b_name, b_data, self }
  
      else
        # Its a default media type body.
        validate_hash 'body', value, String
        media_type = default_media_type
        raise InvalidMediaType, 'Body with no media type, but default media type has not been declared.' unless media_type
        Body.new media_type, value, self
      end
    end

    def parse_headers(value)
      validate_hash 'headers', value, String, Hash

      value.map { |hname, hdata| Header.new hname, hdata, self }
    end
  end
end
