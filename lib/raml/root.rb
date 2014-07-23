module Raml
  class Root
    attr_accessor :children
    attr_accessor :title, :version, :base_uri, :base_uri_parameters,
      :protocols, :media_type, :schemas, :uri_parameters, :documentation, :resources

    def initialize(root_data)
      @children = []

      root_data.each do |key, value|
        if key.start_with?('/')
          @children << Resource.new(key, value)
        elsif key == 'documentation'
          value.each do |document|
            @children << Documentation.new(document["title"], document["content"])
          end
        else
          self.send("#{Raml.underscore(key)}=", value)
        end
      end

      validate
    end

    def document(verbose = false)
      result = ""
      lines = []

      lines << "# #{title}" if title
      lines << "Version: #{version}" if version

      @children.each do |child|
        lines << child.document
      end

      result = lines.join "\n"

      puts result if verbose
      result
    end

    def documents
      @children.select{|child| child.is_a? Documentation}
    end

    private

    def validate
      raise RootTitleMissing   if title.nil?
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
