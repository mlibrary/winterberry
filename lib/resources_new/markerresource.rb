class MarkerResource < Resource

  def process()
    node_list = resource_node_list
    node_list.each do |node|
      path = resource_path(node)
      action = resource_action(path)
      puts path
      puts action
    end
  end

  def resource_node_list
    @resource_node.xpath(".//comment()")
  end

  def resource_path(resource_node)
    resource_node.text.strip
    #resource_node.text.match("<img>([^\"]+)</img>")[1].strip
  end

  def resource_action(path)
    if @resource_actions != nil
      action = @resource_actions.find { |row|
                      row['resource_name'] == path
                    }
      return action
    end
    nil
  end
end