class MarkerResource < Resource

  def process
    node_list = resource_node_list
    node_list.each do |node|
      path = resource_path(node)
      action = resource_action(path)
      metadata = resource_metadata(path)
      puts "#{action['resource_action']}: #{path}"
      #puts action
      #puts metadata

      marker_action = MarkerActionFactory.create(node, action)
      #puts "marker_action: #{marker_action}"
      marker_action.process(:resource_metadata => metadata) unless marker_action == nil
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
    action = @resource_actions.find { |row| row['resource_name'] == path } \
              unless @resource_actions == nil
    return action unless action == nil
    return @default_action
  end
end