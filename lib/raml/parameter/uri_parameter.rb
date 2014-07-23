module Raml
  module Parameter
    class UriParameter < AbstractParameter
      def validate
        # required default to true for URI parameters
        @required = true if required.nil?
        super
      end
    end
  end
end

