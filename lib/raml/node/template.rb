require 'active_support/core_ext/string'

module Raml
  class Template < ValueNode
    
    # @private
    def interpolate(params)
      name = @name.clone
      data = clone_data
      interpolate_params name, params
      interpolate_params data, params
      [ name, data ]
    end

    private

    def clone_data
      # ugly but effective
      Marshal.load Marshal.dump @value
    end

    def interpolate_params(value, params)
      case value
      when String
        interpolate_params_string value, params
      when Hash
        value.map! { |key,val| [ interpolate_params(key, params), interpolate_params(val, params) ] }
      when Array
        value.map! { |val| interpolate_params val, params }
      else
        value
      end
    end

    def interpolate_params_string(value, params)
      value = value.dup if value.frozen?

      value.gsub!(/(<<([^!\s>]+)(?:\s*\|\s*!(\w+))?>>)/) do |match|
        param_name = $2
        function   = $3

        param = params[param_name]
        raise UnknownTypeOrTraitParameter, "#{param_name} is not a known parameter." if param.nil?

        if function
          raise UnknownTypeOrTraitParamFunction, function unless [ 'singularize', 'pluralize'].include? function
          param = param.send function
        end

        param
      end
      value
    end
  end
end