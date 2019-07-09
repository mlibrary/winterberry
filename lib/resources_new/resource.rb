class Resource
	def initialize(args)
		@resource_node = args[:resource_node]
		@resource_actions = args[:resource_actions]
		@resource_metadata = args[:resource_metadata]
	end

	def process()
		puts @resource_node
	end
end