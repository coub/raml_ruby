module Raml
  module Parent
    # @!attribute [rw] children
    #   @return [Array<Raml::Node>] children nodes.
    attr_accessor :children

    private

    def self.included(base)
      base.extend ClassMethods
    end

    # @private
    module ClassMethods
      def child_of(name, type)
        type = [ type ] unless type.is_a? Array

        self.instance_eval do
          define_method name do
            @children.select { |child| type.include? child.class }.first
          end
        end
      end

      def children_of(name, type)
        type = [ type ] unless type.is_a? Array

        self.instance_eval do
          define_method name do
            @children.select { |child| type.include? child.class }
          end
        end
      end

      def children_by(name, key, type, merge_parents=false)
        self.instance_eval do
          define_method name do
            result = Hash[
              @children.
                select { |child| child.is_a? type }.
                map    { |child| [ child.send(key.to_sym), child ] }
            ]

            if merge_parents and parent and parent.respond_to? name
              result = parent.send(name).merge result
            end

            result
          end
        end
      end
    end
  end
end