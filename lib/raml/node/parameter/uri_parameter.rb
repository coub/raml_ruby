module Raml
  module Parameter
    class UriParameter < AbstractParameter
      attr_reader_default :required, true
    end
  end
end