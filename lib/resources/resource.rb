class Resource
  attr_reader :resource_node, :default_action

	def initialize(args)
	  @resource_args = args
		@resource_node = args[:resource_node]
		@resource_actions = args[:resource_actions]
		@resource_metadata = args[:resource_metadata]
		@default_action = args[:default_action]
	end

  def resource_metadata(file_path)
    @resource_metadata.find { |row| row['file_name'] == file_path } unless @resource_metadata == nil
  end

  def clone_default_action(args)
    action = @default_action.clone
    action['resource_name'] = args[:resource_name]
    action['file_name'] = args[:file_name]
    action
  end
end