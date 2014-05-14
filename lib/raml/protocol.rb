module Raml
  class Protocol
    extend Common
    is_documentable

    attr_accessor :http, :https

    def initialize(protocol_data)
      unless protocol_data.is_a?(Array) && protocol_data.select{|e| !e.is_a?(String)}.empty?
        raise ProtocolMustBeArrayOfStrings.new(inspect(protocol_data))
      end

      if protocol_data.select{|protocol| !['HTTP', 'HTTPS'].include?(protocol)}.any?
        raise ProtocolMustBeHTTPorHTTPS.new(protocol_data.inspect)
      end

      @http = true if protocol_data.include? "HTTP"
      @https = true if protocol_data.include? "HTTPS"
    end

    def http?
      @http || false
    end

    def https?
      @https || false
    end
  end
end
