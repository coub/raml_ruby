module Raml
  module Merge
  	def merge_attributes(attributes, base)
      attributes.each do |attr|
        attr_var = "@#{attr}".to_sym
        if instance_variable_get(attr_var).nil? and not (val = base.instance_variable_get(attr_var)).nil?
          instance_variable_set attr_var, val
        end
      end
   	end

		def merge_parameters(base, type, name=:name)
    	match, no_match = base.send(type).values.partition { |param| self.send(type).has_key? param.send(name) }
    	match.each { |param| self.send(type)[param.send name].merge param }
    	@children += no_match
    end
  end
end