module Raml
  class Root
    attr_accessor :title, :version, :base_uri, :base_uri_parameters, :protocols, :media_type, :schemas, :uri_parameters, :documentation, :resources

    def initialize(root_data)
      @resources = {}

      root_data.each do |key, value|
        if key.start_with?('/')
          @root.resources[key] = Resource.new(value)
        else
          @root.send("#{underscore(key)}=", value)
        end
      end

      validate
    end

    private

    def validate
      raise RootTitleMissing if title.nil?
      raise RootBaseUriMissing if base_uri.nil?

    end

    # def validate_base_uri
    #   var_regex = /{(.*?)}/

    #   vars = base_uri.scan(var_regex).flatten
    #   vars.each do |var|

    #   end
    # end
  end
end
