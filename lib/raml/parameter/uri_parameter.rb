module Raml
  module Parameter
    class UriParameter < AbstractParameter
      def set_defaults
        self.required = true if required.nil?
        super
      end
    end
  end
end