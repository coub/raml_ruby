module Raml
  module Parameter
    class AbstractParameter < Node
      VALID_TYPES = %w(string number integer date boolean file)
      BOOLEAN_ATTRIBUTES = %w(repeat required)

      attr_accessor :displayName, :description, :type, :enum,
        :pattern, :min_length, :max_length, :minimum, :maximum,
        :example, :repeat, :required, :default

      def initialize(param)
        if param.is_a? Array
          raise "Named Parameters With Multiple Types are not implemented"
        elsif param.is_a? Hash
          param.each { |name, value| instance_variable_set("@#{underscore(name)}", value) }

          set_defaults
          validate
        end
      end

      private

      def set_defaults
        self.type ||= 'string'
      end

      def validate
        raise InvalidParameterType.new() if !VALID_TYPES.include?(type)

        if type != 'string' && (min_length || max_length)
          raise NamedParameterNotApplicable.new('minLength and maxLength attributes are applicable only for parameters of type string')
        end

        if !%w(integer number).include?(type) && (minimum || maximum)
          raise NamedParameterNotApplicable.new('minimum and maximum attributes applicable only for parameters of type number or integer')
        end

      end
    end
  end
end
