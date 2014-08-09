module Raml
  module Documentable
    attr_accessor :name, :display_name, :description

    def document
      lines = [ "#{@display_name || @name}\n#{@description}" ]
      lines += @children.map { |child| child.document } if @children
      lines.join "\n\n"
    end

    def validate
      [ :display_name, :description ].each do |prop|
        raise InvalidProperty, "#{Raml.camel_case prop} property mus be a string." unless [ NilClass, String ].include? send(prop).class
      end
    end
  end
end