module Raml
  # @private
  module Merge
    def merge(other)
      other.scalar_properties.each do |prop|
        prop_var  = "@#{prop}"
        prop_val = other.instance_variable_get prop_var
        instance_variable_set prop_var, prop_val unless prop_val.nil?
      end
    end

    def merge_properties(other, type)
      match, no_match = other.send(type).values.partition { |param| self.send(type).has_key? param.name }

      match.each { |param| self.send(type)[param.name].merge param }

      # if its an optional property, and there is no match in self, don't merge it.
      no_match.reject! { |node| node.optional      }
      no_match.map!    { |node| node.clone         }
      no_match.each    { |node| node.parent = self }
      @children += no_match
    end
  end
end
