module Raml
  class Method < AbstractMethod
    inherit_class_attributes

    NAMES = %w(options get head post put delete trace connect patch)

    # @!attribute [r] traits
    #   @return [Array<Raml::Trait, Raml::TraitReference>] the traits and trait references.

    non_scalar_property :is

    children_of :traits, [ Trait, TraitReference ]

    # @private
    def apply_traits
      # We apply resource traits before method traits, and apply traits at each level in
      # the other they are listed (first to last, left to righ).  Later traits scalar
      # properties overwrite earlier ones.  We end by merging a copy of the method, so
      # that scalar properties in the method hierarchy overwrite those in the traits.
      # We must apply the traits against the method first, as they may contain optional
      # properties that depend on the method hiearchy.
      cloned_self = self.clone

      (@parent.traits + traits).
        map  { |trait| instantiate_trait trait }.
        each { |trait| merge trait }

      merge cloned_self
    end

    # @private
    def merge(other)
      super

      merge_properties other, :headers
      merge_properties other, :query_parameters
      merge_properties other, :bodies
      merge_properties other, :responses

      # We may be applying a resource type, which will result in the merging of a method that may have
      # traits, instead of a trait that can't have no traits.
      if other.is_a? Method
        # merge traits. insert the non-matching ones in the front, so they have the least priority.
        match, no_match = other.traits.partition do |other_trait|
          if other_trait.is_a? Trait
            false
          else # TraitReference
            self.traits.any? do |self_trait|
              self_trait.is_a?(TraitReference)                &&
              self_trait.name       == other_trait.name       &&
              self_trait.parameters == other_trait.parameters
            end
          end
        end
        @children.unshift(*no_match)
      end

      self
    end

    private

    def validate_name
      raise InvalidMethod, "#{@name} is an unsupported HTTP method" unless NAMES.include? @name
    end

    def validate_parent
      raise InvalidParent, "Parent of method cannot be nil." if @parent.nil?
    end

    def parse_is(value)
      validate_array :is, value, [String, Hash]

      value.map do |trait|
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

    def instantiate_trait(trait)
      reserved_params = {
        'resourcePath'     => @parent.resource_path,
        'resourcePathName' => @parent.resource_path_name,
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