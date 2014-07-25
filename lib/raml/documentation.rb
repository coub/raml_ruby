module Raml
  class Documentation
    attr_accessor :title, :content

    def initialize(title, content)
      @title   = title
      @content = content
      raise InvalidProperty, 'document title cannot be empty.'   if title.nil?   or title.empty?
      raise InvalidProperty, 'document content cannot be empty.' if content.nil? or content.empty?
    end

    def document
      ["####{@title}", "#{@content}"].join "\n"
    end
  end
end
