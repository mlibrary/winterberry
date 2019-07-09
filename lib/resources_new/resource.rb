class Resource
  attr_reader :resource_node

	def initialize(args)
		@resource_node = args[:resource_node]
		@resource_actions = args[:resource_actions]
		@resource_metadata = args[:resource_metadata]
		@default_action = args[:default_action]
	end

  def resource_metadata(file_path)
    @resource_metadata.find { |row| row['file_name'] == file_path }
  end
end