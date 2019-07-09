class ResourceProcessor
	def initialize(args)
		@processor_args = args
	end

	def process(doc)
		resource_node_list = resources(doc)

		args = @processor_args.clone
		resource_node_list.each do |resource_node|
			#puts resource_node
			args[:resource_node] = resource_node
			resource = ResourceFactory.create(args)
			resource.process()
		end
	end

	def resources(doc)
		doc.xpath("//*[@class='fig' or @class='rb']")
	end
end
