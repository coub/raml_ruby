module Raml
  class Resource
    attr_accessor :children

    extend Common

    is_documentable

    def initialize(name, resource_data)
      @children = []
      @name = name

      resource_data.each do |key, value|
        if key.start_with?('/')
          @children << Resource.new(key, value)
        elsif Raml::Method::NAMES.include?(key)
          @children << Method.new(key, value)
        elsif key == "uriParameters"
          value.each do |name, uri_parameter_data|
            @children << Parameter::UriParameter.new(name, uri_parameter_data)
          end
        else
          send("#{Raml.underscore(key)}=", value)
        end
      end
    end

    def document
      doc = ''
      doc << "**#{display_name || name}**\n"
      doc << "#{description}\n" if description
      doc << children.map(&:document).compact.join('\n')
      doc
    end

    def resources
      children.select {|child| child.is_a? Resource}
    end

    def methods
      children.select {|child| child.is_a? Method}
    end

    def uri_parameters
      children.select {|child| child.is_a? UriParameters}
    end
  end
end
