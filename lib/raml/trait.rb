module Raml
  class Trait < AbstractMethod
    attr_accessor :usage

    def document
      lines = []
      lines << "####{}**#{@display_name || @name}**"
      lines << "#{@description}"

      lines << "Supported HTTP protocols: %s" % protocols.join(', ')

      if headers.any?
        lines << "**Headers:**"
        headers.each do |header|
          lines << header.document
        end
      end

      if query_parameters.any?
        lines << "**Query Parameters:**"
        query_parameters.each do |query_parameter|
          lines << query_parameter.document
        end
      end

      if bodies.any?
        lines << "**Body:**"
        bodies.each do |body|
          lines << body.document
        end
      end

      if responses.any?
        lines << "**Responses:**"
        responses.each do |response|
          lines << response.document
        end
      end

      lines.join "  \n"
    end
  end
end