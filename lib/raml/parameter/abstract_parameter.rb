module Raml
  module Parameter
    class AbstractParameter < Node
      attr_accessor :displayName, :description, :type, :enum,
        :pattern, :minLength, :maxLength, :minimum, :maximum,
        :example, :repeat, :required, :default

      def initialize(param)
        param.each { |name, value| instance_variable_set("@#{underscore(name)}", value) }
      end
    end
  end
end
