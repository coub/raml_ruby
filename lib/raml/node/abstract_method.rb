module Raml
  class AbstractMethod < PropertiesNode
    inherit_class_attributes
    
    include Documentable
    include Global
    include Merge
    include Parent
    include Validation
    include Bodies
    include Headers
    include SecuredBy

    # @!attribute [rw] protocols
    #   @return [Array<String>, nil] the supported protocols. Nil or an array of up to two string
    #     elements from the set "HTTP" and "HTTPS".

    # @!attribute [r] query_parameters
    #   @return [Hash<String, Raml::Parameter::QueryParameter>] the method query parameters, keyed
    #     by the parameter name. 

    # @!attribute [r] responses
    #   @return [Hash<Integer, Raml::Response>] the method responses, keyed by the HTTP status code.

    scalar_property     :protocols
    non_scalar_property :query_parameters, :responses, :secured_by

    attr_reader_default :protocols, []

    children_by :query_parameters , :name       , Parameter::QueryParameter
    children_by :responses        , :name       , Response
    children_by :secured_by       , :name       , SecuritySchemeReference
    
    private

    def validate
      _validate_secured_by
    end

    def validate_protocols
      if @protocols
        validate_array :protocols, @protocols, String
        
        @protocols.map!(&:upcase)
        
        raise InvalidProperty, 'protocols property elements must be HTTP or HTTPS' unless 
          @protocols.all? { |p| [ 'HTTP', 'HTTPS'].include? p }
      end
    end

    def parse_query_parameters(value)
      validate_hash 'queryParameters', value, String, Hash
      value.map { |p_name, p_data| Parameter::QueryParameter.new p_name, p_data, self }
    end

    def parse_responses(value)
      validate_hash 'responses', value, [Integer, String], Hash
      value.map { |r_name, r_data| Response.new r_name, r_data, self }
    end
  end
end
