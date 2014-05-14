module Raml
  module Parameter
    class UriParameter < AbstractParameter
      def document
        lines = []
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

        lines.join "  \n"
      end
    end
  end
end

