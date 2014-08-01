module Raml
  class Method < AbstractMethod
    NAMES = %w(options get head post put delete trace connect patch)

    def initialize(name, method_data, root)
      is = method_data.delete('is') || []

      super

      validate_is is
      
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

    def traits
      children.select { |child| child.is_a? Trait }
    end

    def trait_references
      children.select { |child| child.is_a? TraitReference }
    end

    private

    def validate
      raise InvalidMethod, "#{@name} is an unsupported HTTP method" unless NAMES.include? @name
      super
    end

    def validate_is(is)
      raise InvalidProperty, 'is property must be an arrary' unless is.is_a? Array
      unless is.all? { |t| [String, Hash].include? t.class }
        raise InvalidProperty, 
          'is property must be an array of items that are trait names, maps of name and params, or definition maps'
      end
    end
  end
end
