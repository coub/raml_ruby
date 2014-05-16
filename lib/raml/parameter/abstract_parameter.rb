module Raml
  module Parameter
    class AbstractParameter
      extend Common

      VALID_TYPES = %w(string number integer date boolean file)
      BOOLEAN_ATTRIBUTES = %w(repeat required)

      is_documentable
      attr_accessor :type, :enum,
        :pattern, :min_length, :max_length, :minimum, :maximum,
        :example, :repeat, :required, :default

      attr_accessor :children

      def initialize(name, parameter_data)
        @name = name
        @children = []

        if parameter_data.is_a? Array
          parameter_data.each do |parameter|
            @children << self.class.new(name, parameter)
          end
        elsif parameter_data.is_a? Hash
          parameter_data.each { |name, value| instance_variable_set("@#{Raml.underscore(name)}", value) }

          set_defaults
          validate
        end
      end

      def document
        lines = []

        if @children.any?
          lines = @children.map &:document
        else
          lines << "**#{@display_name || @name}**"
          lines << "#{@description}"
          lines << "type: #{@type}" if @type
          lines << "required: #{@required}" if @required
          lines << "enum: #{@enum}" if @enum
          lines << "pattern: #{@pattern}" if @pattern
          lines << "min_length: #{@min_length}" if @min_length
          lines << "max_length: #{@max_length}" if @max_length
          lines << "minimum: #{@minimum}" if @minimum
          lines << "maximum: #{@maximum}" if @maximum
          lines << "example: `#{@example}`" if @example
          lines << "repeat: #{@repeat}" if @repeat
        end

        lines.join "  \n"
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

        if repeat && ![true, false].include?(repeat)
          raise AttributeMustBeTrueOrFalse.new(self)
        end

        if required && ![true, false].include?(required)
          raise AttributeMustBeTrueOrFalse.new(self)
        end
      end
    end
  end
end
