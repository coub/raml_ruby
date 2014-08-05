module Raml

  module Common
    def is_documentable
      attr_accessor :description
      attr_accessor :display_name
      attr_accessor :name

      self.instance_eval do
        define_method :document do
          lines = [ "#{@display_name || @name}\n#{@description}" ]
          lines += @children.map { |child| child.document } if @children
          lines.join "\n\n"
        end
      end
    end

    def has_name
      attr_accessor :name
    end

    def child_of(name, type)
      type = [ type ] unless type.is_a? Array

      self.instance_eval do
        define_method name do
          @children.select { |child| type.include? child.class }.first
        end
      end
    end

    def children_of(name, type)
      type = [ type ] unless type.is_a? Array
      
      self.instance_eval do
        define_method name do
          @children.select { |child| type.include? child.class }
        end
      end
    end

    def children_by(name, key, type)
      self.instance_eval do
        define_method name do
          Hash[
            @children.
              select { |child| child.is_a? type }.
              map    { |child| [ child.send(key.to_sym), child ] }
          ]
        end
      end
    end
  end

  # Transforms camel cased identificators to underscored.
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

