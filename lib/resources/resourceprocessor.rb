class ResourceProcessor
	def initialize(args)
		@processor_args = args
	end

	def process(doc)
		resource_node_list = resources(doc)

		args = @processor_args.clone

		result = false
		resource_node_list.each do |resource_node|
			args[:resource_node] = resource_node
			resource = ResourceFactory.create(args)
			rc = resource.process()
			result = rc if rc == true
		end

		return result
	end

	def resources(doc)
		#doc.xpath("//*[@class='fig' or @class='rb']")
		doc.xpath("//*[@class='fig']") + doc.xpath("//*[@class='rb']")
	end
end
