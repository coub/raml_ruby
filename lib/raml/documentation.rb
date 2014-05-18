module Raml
  class Documentation
    attr_accessor :title, :content

    def initialize(title, content)
      @title = title
      @content = content
    end

    def document
      ["####{@title}", "#{@content}"].join "\n"
    end
  end
end
