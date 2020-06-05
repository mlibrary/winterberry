class MarkerResource < Resource

  def create_actions
    options = @resource_args[:options]

    action_list = []

    node_list = resource_node_list
    node_list.each do |node|
      path = resource_path(node)
      action = resource_action(path)
      metadata = resource_metadata(path)

      if metadata != nil
        action = MarkerActionFactory.create(
                    :resource => self,
                    :resource_action => action,
                    :resource_img => node,
                    :resource_metadata => metadata
                    )
        action_list << action
      end

    end

    return action_list
  end

  # Return the nodes that reference resources.
  # For marker callouts, this should be within
  # a XML comment, but not always the case.
  # NOTE: either display warning if no comment,
  # or just use the node content?
  def resource_node_list
    node_list = @resource_node.xpath(".//comment()")
    return node_list unless node_list.nil? or node_list.empty?
    return [ @resource_node ]
  end

  # Parse the callout text for the path
  def resource_path(resource_node)
    resource_node.text.strip
    #resource_node.text.match("<img>([^\"]+)</img>")[1].strip
  end

  def resource_action(path)
    c_resource_action('resource_name', path)
  end
end