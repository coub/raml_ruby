module Raml
  class Documentation < PropertiesNode
    scalar_property :content
    alias_method :title, :name

    def document
      ["####{title}", "#{content}"].join "\n"
    end

    private

    def validate
      raise InvalidProperty, 'document title cannot be empty.'   if title.nil?   or title.empty?
      raise InvalidProperty, 'document content cannot be empty.' if content.nil? or content.empty?
    end
  end
end
