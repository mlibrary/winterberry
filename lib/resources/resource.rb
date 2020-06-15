class Resource
  attr_reader :resource_node

	def initialize(args)
	  @resource_args = args
		@resource_node = args[:resource_node]
		@resource_actions = args[:resource_actions]
		@default_action_str = args[:default_action_str]
	end

  def reference_type
    return @resource_args[:reference_type]
  end

  def reference_action(path)
    resource_action = @resource_actions.find {|a| a.reference == path }
    return resource_action unless resource_action.nil?

    reference = ResourceMapReference.new(:name => path)
    return ReferenceAction.new(
           :resource_map_action => ResourceMapAction.new(
                                       :reference => reference,
                                       :resource => nil,
                                       :type => @default_action_str
                                   ),
           :resource_metadata => nil
         )
  end
end