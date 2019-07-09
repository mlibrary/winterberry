class ResourceProcessor
	def initialize(args)
		@monograph_metadata = args[:resource_metadata]
		@actions = args[:resource_actions]
		@default_action = args[:default_action]
	end

	def process(doc)
		resource_node_list = resources(doc)
		resource_node_list.each do |resource_node|
			#puts resource_node
			resource = ResourceFactory.create(
					:resource_node => resource_node, 
					:resource_actions => @actions,
					:resource_metadata => @monograph_metadata
					)
			resource.process()
		end
	end

	def resources(doc)
		doc.xpath("//*[(local-name()='div' and @class='fig') or (local-name()='p' and @class='rb')]")
	end
end
