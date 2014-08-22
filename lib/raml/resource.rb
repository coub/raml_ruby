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
          validate_property :type, value, [ Hash, String ]
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

    children_by :resources, :name, Resource

    child_of :type, [ ResourceType, ResourceTypeReference ]

    def apply_traits
      super
      resources.values.each(&:apply_traits)
    end
  end
end
