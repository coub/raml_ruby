module Raml
	module Validation
		def validate_property(name, value, classes)
      classes = [ classes ] unless classes.is_a? Array
      raise InvalidProperty, "#{Raml.camel_case name} property must be an #{classes_to_s classes}" unless classes.include? value.class
    end

		def validate_string(name, string)
			validate_property name, string, String
      raise InvalidProperty, "#{Raml.camel_case name} property must be a non-empty string." if     string.empty?
		end

		def validate_array(name, array, element_classes=nil)
      raise InvalidProperty, "#{Raml.camel_case name} property must be an array" unless
      	array.is_a? Array

      if element_classes
      	element_classes = [ element_classes ] unless element_classes.is_a? Array
	      raise InvalidProperty, "#{Raml.camel_case name} property must be an array of #{classes_to_s element_classes}" unless
	        array.all? { |element| element_classes.include? element.class }
      end
		end

		def validate_hash(name, hash, key_class=nil, value_class=nil)
      raise InvalidProperty, "#{Raml.camel_case name} property must be a map" unless 
        hash.is_a? Hash

			if key_class
	      raise InvalidProperty, "#{Raml.camel_case name} property must be a map with #{key_class} keys" unless
	        hash.keys.all?  {|key| key.is_a? key_class }
      end

      if value_class
	      raise InvalidProperty, "#{Raml.camel_case name} property must be a map with map values" unless
	        hash.values.all?  {|value| value.is_a? Hash }      
	    end
		end

		def classes_to_s(classes)
			classes.join(', ').gsub(/, (\w)\z/, ' or \1')
		end
	end
end