module Raml
  module Documentable
    def self.included(base)
      base.instance_eval do
        scalar_property :display_name, :description
      end
    end

    def document
      lines = [ "#{@display_name || @name}\n#{@description}" ]
      lines += @children.map { |child| child.document } if @children
      lines.join "\n\n"
    end

    private

    def validate_display_name
      raise InvalidProperty, "displayName property mus be a string." unless display_name.is_a? String 
    end

    def validate_description
      raise InvalidProperty, "description property mus be a string." unless description.is_a? String 
    end
  end
end