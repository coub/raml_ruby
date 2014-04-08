module Raml
  class Root
    attr_accessor :title, :version, :base_uri, :base_uri_parameters, :protocols, :media_type, :schemas, :uri_parameters, :documentation, :resources

    def initialize()
      @resources = {}
    end
  end
end
