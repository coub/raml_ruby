module Raml
  class Resource < AbstractResource
    def initialize(name, resource_data, root)
      @children ||= []

      resource_data.delete_if do |key, value|
        case key
        when /\A\//
          @children << Resource.new(key, value, root)
          true

        when 'type'
          validate_type value
          if value.is_a? Hash
            if value.keys.size == 1 and root.resource_types.include? value.keys.first
              raise InvalidProperty, 'type property with map of resource type name but params are not a map' unless 
                value.values[0].is_a? Hash
              @children << ResourceTypeReference.new( *value.first )
            else
              @children << ResourceType.new('_', value, root)
            end
          else
            @children << ResourceTypeReference.new(value)
          end
          true

        else
          false
        end
      end
      
      super
    end

    def resources
      children.select { |child| child.is_a? Resource }
    end

    def type
      children.select { |child| child.is_a? ResourceType }.first
    end

    def type_reference
      children.select { |child| child.is_a? ResourceTypeReference }.first
    end
    
    private
    
    def validate_type(type)
      raise InvalidProperty, 'type property must be a string resource type reference or a reference type definition map.' unless
        [ Hash, String ].include? type.class
    end
  end
end
