module Raml
  module Parent
    def self.included(base)
      base.extend ClassMethods
    end

    attr_accessor :children

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

      def children_by(name, key, type)
        self.instance_eval do
          define_method name do
            Hash[
              @children.
                select { |child| child.is_a? type }.
                map    { |child| [ child.send(key.to_sym), child ] }
            ]
          end
        end
      end
    end
  end
end