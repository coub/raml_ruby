module Raml
  class AbstractResource
    include Documentable
    include Parent
    include Validation

    def initialize(name, resource_data, root)
      @children ||= []
      @name = name

      resource_data.each do |key, value|
        case key
        when *Raml::Method::NAMES
          @children << Method.new(key, value, root)

        when 'uriParameters'
          validate_hash key, value, String, Hash
          @children += value.map { |uname, udata| Parameter::UriParameter.new uname, udata }

        when 'baseUriParameters'
          validate_base_uri_parameters value
          @children += value.map { |bname, bdata| Parameter::BaseUriParameter.new bname, bdata }

        when 'is'
          validate_array key, value, [String, Hash]
          @children += value.map do |trait|
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


        else
          begin
            send "#{Raml.underscore(key)}=", value
          rescue
            raise UnknownProperty, "#{key} is an unknown property."
          end
        end
      end
      
      validate
    end

    def document
      doc = ''
      doc << "**#{display_name || name}**\n"
      doc << "#{description}\n" if description
      doc << children.map(&:document).compact.join('\n')
      doc
    end

    children_by :methods            , :name, Raml::Method
    children_by :base_uri_parameters, :name, Parameter::BaseUriParameter
    children_by :uri_parameters     , :name, Parameter::UriParameter

    children_of :traits, [ Trait, TraitReference ]

    def apply_traits
      methods.values.each { |method| method.apply_traits traits }
    end

    private
        
    def validate_base_uri_parameters(base_uri_parameters)
      validate_hash :base_uri_parameters, base_uri_parameters, String, Hash
      
      raise InvalidProperty, 'baseUriParameters property can\'t contain reserved "version" parameter' if
        base_uri_parameters.include? 'version'
    end
  end
end
