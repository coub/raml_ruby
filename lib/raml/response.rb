module Raml
  class Response
    include Documentable
    include Merge
    include Parent
    include Validation

    def initialize(name, response_data, root)
      @children = []
      @name = name

      response_data.each do |key, value|
        case key
        when 'body'
          validate_hash key, value, String, Hash
          @children += value.map { |bname, bdata| Body.new bname, bdata, root }
        
        when 'headers'
          validate_hash key, value, String, Hash
          @children += value.map { |hname, hdata| Header.new hname, hdata }

        else
          begin
            send "#{Raml.underscore(key)}=", value
          rescue
            raise UnknownProperty, "#{key} is an unknown property."
          end
        end
      end
      
      validate
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

    children_by :bodies , :media_type, Body
    children_by :headers, :name      , Header

    def merge(base)
      raise MergeError, "Response status codes don't match." if name != base.name

      super
      merge_parameters base, :headers
      merge_parameters base, :bodies          , :media_type

      self
    end
  end
end
