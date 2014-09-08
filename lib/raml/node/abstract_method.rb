module Raml
  class AbstractMethod < Node
    include Documentable
    include Global
    include Merge
    include Parent
    include Validation

    ABSTRACT_METHOD_ATTRIBUTES = [ :protocols ]

    attr_accessor(*ABSTRACT_METHOD_ATTRIBUTES)

    attr_reader_default :protocols, []

    def initialize(name, method_data, parent)
      @children = []
      @name     = name
      @parent   = parent
      
      method_data.each do |key, value|
        case key
        when 'headers'
          validate_hash key, value, String, Hash
          @children += value.map { |h_name, h_data| Header.new h_name, h_data, self }

        when 'queryParameters'
          validate_hash key, value, String, Hash
          @children += value.map { |p_name, p_data| Parameter::QueryParameter.new p_name, p_data, self }

        when 'body'
          validate_hash key, value, String, Hash
          @children += value.map { |b_name, b_data| Body.new b_name, b_data, self }

        when 'responses'
          validate_hash key, value, Integer, Hash
          @children += value.map { |r_name, r_data| Response.new r_name, r_data, self }

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

    children_by :headers          , :name       , Header
    children_by :query_parameters , :name       , Parameter::QueryParameter
    children_by :bodies           , :media_type , Body
    children_by :responses        , :name       , Response

    def merge(base)
      super
      merge_attributes ABSTRACT_METHOD_ATTRIBUTES, base
      merge_parameters base, :headers
      merge_parameters base, :query_parameters
      merge_parameters base, :bodies          , :media_type
      merge_parameters base, :responses

      self
    end

    private
    
    def validate
      super      
      validate_protocols
    end
    
    def validate_protocols
      if @protocols
        validate_array :protocols, @protocols, String
        
        @protocols.map!(&:upcase)
        
        raise InvalidProperty, 'protocols property elements must be HTTP or HTTPS' unless 
          @protocols.all? { |p| [ 'HTTP', 'HTTPS'].include? p }
      end
    end
  end
end
