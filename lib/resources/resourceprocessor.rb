class ResourceProcessor
	def initialize(args)
		@processor_args = args
	end

	def process(doc)
		resource_node_list = resources(doc)

		args = @processor_args.clone

    options = @processor_args[:options]

    action_list = []
		resource_node_list.each do |resource_node|
			args[:resource_node] = resource_node
			resource = ResourceFactory.create(args)
			actions = resource.create_actions()
      action_list += actions

			if options.execute
			  actions.each do |action|
			    action.process
			    puts action
			  end
			end
		end

    return action_list
	end

	def resources(doc)
		#doc.xpath("//*[@class='fig' or @class='rb']")
		doc.xpath("//*[@class='fig']") + doc.xpath("//*[@class='rb']")
	end
end
