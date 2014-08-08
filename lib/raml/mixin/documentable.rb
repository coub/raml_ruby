module Raml
  module Documentable
    attr_accessor :description
    attr_accessor :display_name
    attr_accessor :name

    def document
      lines = [ "#{@display_name || @name}\n#{@description}" ]
      lines += @children.map { |child| child.document } if @children
      lines.join "\n\n"
    end
  end
end