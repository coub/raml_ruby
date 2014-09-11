module Raml
  module Optional
    def initialize(name, properties, parent)
      @optionals = []
      properties = properties.dup
      properties.map! do |prop_name, prop_value|
      	prop_name = prop_name.to_s
      	if prop_name.end_with? '?'
      		prop_name.chomp! '?'
      		@optionals << Raml.underscore(prop_name)
      	end

      	[ prop_name, prop_value ]
      end

      super name, properties, parent
    end
  end
end