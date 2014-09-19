require 'kramdown'

module Raml
  module Documentable
    def self.included(base)
      base.instance_eval do
        scalar_property :display_name, :description
      end
    end

    def html_description
      Kramdown::Document.new(description, input: :GFM).to_html
    end

    private

    def validate_display_name
      raise InvalidProperty, "displayName property mus be a string." unless display_name.is_a? String 
    end

    def validate_description
      raise InvalidProperty, "description property mus be a string." unless description.is_a? String 
    end
  end
end