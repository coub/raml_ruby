module Raml
  class ResourceType < AbstractResource
  	attr_accessor :usage

    def initialize(name, resource_data, root)
    	super
    rescue NoMethodError => e
      if e.name.to_s.start_with? '/'
      	raise InvalidResourceType, 'Resource type definition cannot have nested resources.'
      else
	      raise
	    end
    end
  end
end
