module Raml
  module Documentable
    DOCUMENTABLE_ATTRIBUTES = [ :display_name, :description ]
    attr_accessor :name, *DOCUMENTABLE_ATTRIBUTES

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

    def merge(base)
      begin
        super
      rescue NoMethodError
      end

      merge_attributes DOCUMENTABLE_ATTRIBUTES, base
    end

    def reset
      super rescue nil
      DOCUMENTABLE_ATTRIBUTES.each { |attr| instance_variable_set "@#{attr}", nil }
    end
  end
end