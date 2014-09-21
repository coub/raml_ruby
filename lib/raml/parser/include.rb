# @private
class Raml::Parser
  class Include
    attr_reader :path
    
    def init_with(coder)
      @path = coder.scalar
    end
    
    def content(cwd)
      pathname = @path.start_with?('/') ? @path : "#{cwd}/#{@path}"
      @content = File.open(pathname).read
      @content = YAML.load @content if is_yaml?
      @content
    rescue => e
      raise Raml::CantIncludeFile, e
    end
    
    private
    
    def is_yaml?
      [ 'yaml', 'yml', 'raml' ].include? @path.split('.').last.downcase
    end
  end
end