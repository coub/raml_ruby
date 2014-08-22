module Raml
  class Method < AbstractMethod
    include Merge

    NAMES = %w(options get head post put delete trace connect patch)

    def initialize(name, method_data, root)
      is = method_data.delete('is') || []

      super

      validate_array :is, is, [String, Hash]

      @children += is.map do |trait|
        if trait.is_a? Hash
          if trait.keys.size == 1 and root.traits.include? trait.keys.first
            raise InvalidProperty, 'is property with map of trait name but params are not a map' unless 
              trait.values[0].is_a? Hash
            TraitReference.new( *trait.first )
          else
            Trait.new '_', trait, root
          end
        else
          TraitReference.new trait
        end
      end
    end

    children_of :traits, [ Trait, TraitReference ]

    def apply_traits(resource_traits)
      # we apply the traits from right to left and method traits before resource traits.
      # this results in higher predecene to rightmost and method traits, as merging
      # will only resylt in params propertie being set if they are not already set.
      (resource_traits + traits).reverse.each { |trait| merge trait }
    end

    private

    def validate
      raise InvalidMethod, "#{@name} is an unsupported HTTP method" unless NAMES.include? @name
      super
    end
  end
end