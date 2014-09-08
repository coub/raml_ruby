module Raml
  class Resource < AbstractResource
    include Merge

    def initialize(name, resource_data, parent)
      @children ||= []
      @parent     = parent

      resource_data.delete_if do |key, value|
        case key
        when /\A\//
          @children << Resource.new(key, value, self)
          true

        when 'type'
          validate_property :type, value, [ Hash, String ]
          if value.is_a? Hash
            if value.keys.size == 1 and resource_type_declarations.include? value.keys.first
              raise InvalidProperty, 'type property with map of resource type name but params are not a map' unless 
                value.values[0].is_a? Hash
              @children << ResourceTypeReference.new( *value.first, self )
            else
              @children << ResourceType.new('_', value, self)
            end
          else
            raise UnknownResourceTypeReference, "#{value} referenced in resource but not found in resource types declaration." unless
              resource_type_declarations.include? value
            @children << ResourceTypeReference.new(value, self)
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

    def apply_resource_type
      merge instantiate_resource_type if type
      resources.values.each(&:apply_resource_type)
    end

    def apply_traits
      super
      resources.values.each(&:apply_traits)
    end

    def merge(base)
      raise MergeError, 'Trying to merge ResourceTypeReference into Resource.' unless base.is_a? ResourceType::Instance

      super

      merge_parameters base, :methods
      merge_parameters base, :base_uri_parameters
      merge_parameters base, :uri_parameters
      # insert them in the front, so they have the least priority
      @children.unshift(*base.traits)

      self
    end

    private

    def instantiate_resource_type
      reserved_params = {
        'resourcePath'     => resource_path,
        'resourcePathName' => resource_path.split('/')[-1]
      }
      if ResourceTypeReference === type
        resource_type_declarations[type.name].instantiate type.parameters.merge reserved_params
      else
        type.instantiate reserved_params
      end
    end
  end
end
