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
          lines << "*#{@display_name || @name}:*"
          lines << "&nbsp;&nbsp;#{@description}" if @description
          lines << "&nbsp;&nbsp;type: #{@type}" if @type
          lines << "&nbsp;&nbsp;required: #{@required}" if @required
          lines << "&nbsp;&nbsp;enum: #{@enum}" if @enum
          lines << "&nbsp;&nbsp;pattern: #{@pattern}" if @pattern
          lines << "&nbsp;&nbsp;min_length: #{@min_length}" if @min_length
          lines << "&nbsp;&nbsp;max_length: #{@max_length}" if @max_length
          lines << "&nbsp;&nbsp;minimum: #{@minimum}" if @minimum
          lines << "&nbsp;&nbsp;maximum: #{@maximum}" if @maximum
          lines << "&nbsp;&nbsp;example: `#{@example}`" if @example
          lines << "&nbsp;&nbsp;repeat: #{@repeat}" if @repeat
          lines << "\n"
        end

        lines.join "  \n"
      end

      private

      def set_defaults
        self.type ||= 'string'
      end

      def validate
        raise InvalidParameterType.new() if !VALID_TYPES.include?(type)
        
        if enum
          if type == 'string'
            raise InvalidParameterAttribute, 'enum attribute must be an array of strings.' unless
              enum.is_a?(Array) && enum.all? { |val| val.is_a? String }
          else
            raise InapplicableParameterAttribute, 'enum attribute is only applicable to string parameters.'
          end
        end

        if pattern
          if type == 'string'
            raise InvalidParameterAttribute, 'pattern attribute must be a string' unless @pattern.is_a? String
            pattern.gsub!(/\\*\^/u) { |m| m.size.odd? ? "#{m.chop}\\A" : m }
            pattern.gsub!(/\\*\$/u) { |m| m.size.odd? ? "#{m.chop}\\z" : m }
            begin
              @pattern = Regexp.new pattern
            rescue RegexpError
              raise InvalidParameterAttribute, 'pattern attribute must be a valid regexp'
            end
          else
            raise InapplicableParameterAttribute, 'pattern attribute is only applicable to string parameters.'
          end          
        end
        
        if type != 'string' && (min_length || max_length)
          raise InapplicableParameterAttribute,
            'minLength and maxLength attributes are applicable only to string parameters.'
        end

        if !%w(integer number).include?(type) && (minimum || maximum)
          raise InapplicableParameterAttribute,
            'minimum and maximum attributes applicable only to number or integer parameters.'
        end

        if !repeat.nil? && ![true, false].include?(repeat)
          raise InvalidParameterAttribute, 'repeat attribute must be true or false.'
        end

        if !required.nil? && ![true, false].include?(required)
          raise InvalidParameterAttribute, 'required attribute must be true or false.'
        end
      end
    end
  end
end
