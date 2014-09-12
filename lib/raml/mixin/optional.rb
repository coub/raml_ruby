module Raml
  module Optional
    def self.included(mod)
      mod.instance_eval do
        attr_reader :optionals
      end
    end

    def initialize(name, properties, parent)
      @optionals = []
      properties = properties.dup
      properties.map! do |prop_name, prop_value|
      	prop_name = prop_name.to_s
      	if prop_name.end_with? '?'
      		prop_name = prop_name.dup
      		prop_name.chomp! '?'
      		@optionals << Raml.underscore(prop_name)
      	end

      	[ prop_name, prop_value ]
      end
      
      super name, properties, parent
    end

    def optional?(type, prop_name)
    	return prop_name unless prop_name.is_a? String

    	if prop_name.end_with? '?'
    		prop_name = prop_name.dup
    		prop_name.chomp! '?'
    		@optionals << Raml.underscore("_#{type}_#{prop_name}")
    	end

    	prop_name
    end
  end
end