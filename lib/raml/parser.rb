require 'yaml'

module Raml
  # @private
  class Parser
    class << self
      def parse(data, file_dir=Dir.getwd)
        register_include_tag
        
        data = YAML.load data
        expand_includes data, file_dir

        Root.new data
      end

      private
      
      def register_include_tag
        YAML.add_tag '!include', Raml::Parser::Include
      end
      
      def expand_includes(val, cwd)
        case val
        when Hash
          val.merge!(val, &expand_includes_transform_hash(cwd))
        when Array
          val.map!(&expand_includes_transform_array(cwd))
        end
      end

      def expand_includes_transform_array(cwd)
        proc do |arg|
          expand_includes_transform(arg, cwd)
        end
      end

      def expand_includes_transform_hash(cwd)
        proc do |arg1, arg2|
          expand_includes_transform(arg2, cwd)
        end
      end

      def expand_includes_transform(val, cwd)
        child_wd = cwd

        if val.is_a? Raml::Parser::Include
          child_wd = expand_includes_working_dir cwd, val.path
          val = val.content cwd
        end

        expand_includes val, child_wd

        val
      end
      
      def expand_includes_working_dir(current_wd, include_pathname)
        include_path = File.dirname include_pathname
        if include_path.start_with? '/'
          include_path
        else
          "#{current_wd}/#{include_path}"
        end
      end
    end
  end
end
