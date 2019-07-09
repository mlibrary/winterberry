class ResourceFactory
	def self.create(args)
		resource_node = args[:resource_node]
		resource_actions = args[:resource_actions]
		resource_metadata = args[:resource_metadata]

		case ResourceFactory.node_type(resource_node)
		when "marker"
			return MarkerResource.new(args)
		when "element"
			return ElementResource.new(args)
		end
		return nil
	end

	def self.node_type(node)
		attr = node.attribute("class")
		attr.text.downcase == "rb" ? "marker" : "element"
	end
end