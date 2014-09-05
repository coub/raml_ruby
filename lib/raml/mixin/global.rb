module Raml
  module Global
  	def trait_declarations
  		@parent.trait_declarations
  	end

  	def resource_type_declarations
  		@parent.resource_type_declarations
  	end

  	def schema_declarations
  		@parent.schema_declarations
  	end
  end
end