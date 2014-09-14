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

    scalar_property     :protocols
    non_scalar_property :query_parameters, :responses, :secured_by

    attr_reader_default :protocols, []

    children_by :query_parameters , :name       , Parameter::QueryParameter
    children_by :responses        , :name       , Response
    
    def document
      lines = []
      lines << "####{}**#{@display_name || @name}**"
      lines << "#{@description}"

      lines << "Supported HTTP protocols: %s" % protocols.join(', ')

      if headers.any?
        lines << "**Headers:**"
        headers.values.each do |header|
          lines << header.document
        end
      end

      if query_parameters.any?
        lines << "**Query Parameters:**"
        query_parameters.values.each do |query_parameter|
          lines << query_parameter.document
        end
      end

      if bodies.any?
        lines << "**Body:**"
        bodies.values.each do |body|
          lines << body.document
        end
      end

      if responses.any?
        lines << "**Responses:**"
        responses.values.each do |response|
          lines << response.document
        end
      end

      lines.join "  \n"
    end

    private
        
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

    def parse_secured_by(data)
      # XXX ignored for now
      []
    end

  end
end
