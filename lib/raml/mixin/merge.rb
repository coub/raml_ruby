module Raml
  module Merge
    def merge(base)
      scalar_properties.each do |prop|
        prop_var  = "@#{prop}".to_sym
        other_val = base.instance_variable_get prop_var
        if instance_variable_get(prop_var).nil? and not other_val.nil?
          instance_variable_set prop_var, other_val
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