class Resource
  attr_reader :resource_node, :default_action

	def initialize(args)
	  @resource_args = args
		@resource_node = args[:resource_node]
		@resource_actions = args[:resource_actions]
		@default_action_str = args[:default_action_str]
	end

=begin
  def clone_default_action(args)
    return @default_action
  end

  def c_resource_action(field, path)
    resource_action = field == 'resource_name' ? \
          @resource_actions.find {|a| a.resource == path } : \
          @resource_actions.find {|a| a.reference == path }
    return resource_action unless resource_action.nil?

    reference = field == 'file_name' ? path : ""
    resource = field == 'resource_name' ? path : ""
    return ReferenceAction.new(
           :resource_map_action => ResourceMapAction.new(
                                       :reference => reference,
                                       :resource => resource,
                                       :type => @default_action_str
                                   ),
           :resource_metadata => nil
         )
  end

  def c_resource_action_old(field, path)
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
=end
end