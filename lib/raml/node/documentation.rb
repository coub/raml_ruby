module Raml
  class Documentation < PropertiesNode

    # @!attribute [rw] content
    #   @return [String] the documentation content.

    # @!attribute [rw] title
    #   @return [String] the documentation title.  An alias for #name.

    scalar_property :content
    alias_method :title, :name

    private

    def validate
      raise InvalidProperty, 'document title cannot be empty.'   if title.nil?   or title.empty?
      raise InvalidProperty, 'document content cannot be empty.' if content.nil? or content.empty?
    end
  end
end
