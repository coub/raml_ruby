module Raml
  module Common
    def is_documentable
      attr_accessor :description
      attr_accessor :display_name
      attr_accessor :name

      self.instance_eval do
        define_method :document do
          name = ["#{@display_name || @name}","#{@description}"].join "\n"

          lines = [name]
          if @children
            @children.each do |child|
              lines << child.document
            end
          end

          lines.join "\n\n"
        end
      end
    end

    def has_name
      attr_accessor :name
    end
  end

  # Transforms camel cased identificators
  # to underscored
  def self.underscore(camel_cased_word)
    camel_cased_word.to_s.gsub(/::/, '/').
      gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
      gsub(/([a-z\d])([A-Z])/,'\1_\2').
      tr("-", "_").
      downcase
  end

  def self.code_indenter(code)
    code.split("\n").map{|line| ' ' * 4 + line}.join("\n")
  end

  def self.nbsp_indenter(text, indent_depth = 4)
    text.split("\n").map{|line| '&nbsp;' * indent_depth + line}.join("\n")
  end
end

