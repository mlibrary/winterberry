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
    #@resource_metadata.find { |row| row['file_name'] == file_path } unless @resource_metadata.nil?
    fileset = @resource_metadata.fileset(file_path) unless @resource_metadata.nil?
    return fileset
  end

  def clone_default_action(args)
    action = @default_action.clone
    action['resource_name'] = args[:resource_name]
    action['file_name'] = args[:file_name]
    return action
  end

  def c_resource_action(field, path)
    action = @resource_actions.find { |row| row[field] == path } \
              unless @resource_actions == nil
    if action != nil
      action_str = action['resource_action'].downcase
      if action_str == 'default'
        action['resource_action'] = @default_action['resource_action']
      end
      return action
    end

    return clone_default_action(:resource_name => path, :file_name => path)
  end
end