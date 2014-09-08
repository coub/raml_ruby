module Raml
  class Method < AbstractMethod
    include Merge

    NAMES = %w(options get head post put delete trace connect patch)

    def initialize(name, method_data, parent)
      is = method_data.delete('is') || []

      super

      validate_array :is, is, [String, Hash]

      @children += is.map do |trait|
        if trait.is_a? Hash
          if trait.keys.size == 1 and trait_declarations.include? trait.keys.first
            raise InvalidProperty, 'is property with map of trait name but params are not a map' unless 
              trait.values[0].is_a? Hash
            TraitReference.new( *trait.first, self )
          else
            Trait.new '_', trait, self
          end
        else
          raise UnknownTraitReference, "#{trait} referenced in method but not found in traits declaration." unless
            trait_declarations.include? trait
          TraitReference.new trait, self
        end
      end
    end

    children_of :traits, [ Trait, TraitReference ]

    def apply_traits
      # we apply the traits from right to left and method traits before resource traits.
      # this results in higher predecene to rightmost and method traits, as merging
      # will only resylt in params propertie being set if they are not already set.
      (@parent.traits + traits).
        reverse.
        map  { |trait| instantiate_trait trait }.
        each { |trait| merge trait }
    end

    private

    def validate
      raise InvalidMethod, "#{@name} is an unsupported HTTP method" unless NAMES.include? @name
      validate_parent
      super
    end

    def validate_parent
      raise InvalidParent, "Parent of method cannot be nil." if @parent.nil?
    end

    def instantiate_trait(trait)
      reserved_params = {
        'resourcePath'     => @parent.resource_path,
        'resourcePathName' => @parent.resource_path.split('/')[-1],
        'methodName'       => self.name
      }
      if TraitReference === trait
        trait_declarations[trait.name].instantiate trait.parameters.merge reserved_params
      else
        trait.instantiate reserved_params
      end
    end
  end
end