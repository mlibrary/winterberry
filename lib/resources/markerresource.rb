class MarkerResource < Resource

  def create_actions
    options = @resource_args[:options]

    action_list = []

    node_list = resource_node_list
    node_list.each do |node|
      path = resource_path(node)
      action = resource_action(path)
      metadata = resource_metadata(path)

      scan_report(
        :resource_action => action,
        :resource_metadata => metadata
        )

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

  def resource_node_list
    @resource_node.xpath(".//comment()")
  end

  def resource_path(resource_node)
    resource_node.text.strip
    #resource_node.text.match("<img>([^\"]+)</img>")[1].strip
  end

  def resource_action(path)
    c_resource_action('resource_name', path)
  end
end