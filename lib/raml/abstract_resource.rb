module Raml
  class AbstractResource
    attr_accessor :children

    extend Common

    is_documentable

    def initialize(name, resource_data, root)
      @children ||= []
      @name = name

      resource_data.each do |key, value|
        case key
        when *Raml::Method::NAMES
          @children << Method.new(key, value, root)

        when 'uriParameters'
          validate_uri_parameters value
          @children += value.map { |uname, udata| Parameter::UriParameter.new uname, udata }

        when 'baseUriParameters'
          validate_base_uri_parameters value
          @children += value.map { |bname, bdata| Parameter::BaseUriParameter.new bname, bdata }

        when 'is'
          validate_is value
          @children += value.map do |trait|
            if trait.is_a? Hash
              if trait.keys.size == 1 and root.traits.any? { |t| t.name == trait.keys[0] }
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

    def methods
      children.select { |child| child.is_a? Method }
    end

    def uri_parameters
      children.select { |child| child.is_a? Parameter::UriParameter }
    end
    
    def base_uri_parameters
      children.select { |child| child.is_a? Parameter::BaseUriParameter }
    end
    
    def traits
      children.select { |child| child.is_a? Trait }
    end

    def trait_references
      children.select { |child| child.is_a? TraitReference }
    end

    private
    
    def validate
      raise InvalidProperty, 'description property mus be a string' unless description.nil? or description.is_a? String
    end
    
    def validate_uri_parameters(uri_parameters)
      raise InvalidProperty, 'uriParameters property must be a map' unless 
        uri_parameters.is_a? Hash
      
      raise InvalidProperty, 'uriParameters property must be a map with string keys' unless
        uri_parameters.keys.all?  {|k| k.is_a? String }

      raise InvalidProperty, 'uriParameters property must be a map with map values' unless
        uri_parameters.values.all?  {|v| v.is_a? Hash }      
    end
    
    def validate_base_uri_parameters(base_uri_parameters)
      raise InvalidProperty, 'baseUriParameters property must be a map' unless 
        base_uri_parameters.is_a? Hash
      
      raise InvalidProperty, 'baseUriParameters property must be a map with string keys' unless
        base_uri_parameters.keys.all?  {|k| k.is_a? String }

      raise InvalidProperty, 'baseUriParameters property must be a map with map values' unless
        base_uri_parameters.values.all?  {|v| v.is_a? Hash }
      
      raise InvalidProperty, 'baseUriParameters property can\'t contain reserved "version" parameter' if
        base_uri_parameters.include? 'version'
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
